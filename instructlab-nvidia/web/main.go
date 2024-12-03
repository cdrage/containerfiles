package main

import (
	"bufio"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"os/exec"
	"strings"
	"sync"
	"time"

	"github.com/gin-gonic/gin"
)

var (
	logMutex           sync.Mutex
	logFilePath        = "logs/script.log"
	currentCmd         *exec.Cmd
	trainingInProgress bool
	trainingMutex      sync.Mutex
	systemInfo         map[string]string
	gpuUsageData       map[string]map[string]string
	dataMutex          sync.Mutex
)

func init() {
	gpuUsageData = make(map[string]map[string]string)
	go updateGPUUsageDataPeriodically()
}

func main() {
	systemInfo = gatherSystemInfo()

	// Ensure logs directory exists
	if err := os.MkdirAll("logs", 0755); err != nil {
		log.Fatalf("Failed to create logs directory: %v", err)
	}

	// Setup router
	r := gin.Default()

	// Serve the "index.html" file for the root route
	r.GET("/", func(c *gin.Context) {
		c.File("./frontend/index.html")
	})

	// Serve other static files in the "frontend" directory
	r.Static("/assets/", "./frontend")

	r.GET("/logs", getLogs)
	r.GET("/state", getTrainingState)
	r.POST("/run", runScript)
	r.POST("/stop", stopScript)
	r.Static("/final", "./final")
	r.GET("/files", listFiles)
	r.GET("/system-info", getSystemInfo)
	r.GET("/gpu-usage", getGPUUsage)

	log.Println("Server running on http://localhost:8080")
	if err := r.Run(":8080"); err != nil {
		log.Fatalf("Failed to start server: %v", err)
	}
}

// Serve logs to the frontend
func getLogs(c *gin.Context) {
	logMutex.Lock()
	defer logMutex.Unlock()

	logFile, err := os.Open(logFilePath)
	if err != nil {
		c.String(http.StatusInternalServerError, "Failed to read logs: %v", err)
		return
	}
	defer logFile.Close()

	scanner := bufio.NewScanner(logFile)
	var logs []string
	for scanner.Scan() {
		logs = append(logs, scanner.Text())
	}

	c.JSON(http.StatusOK, logs)
}

// Stop the bash script
func stopScript(c *gin.Context) {
	trainingMutex.Lock()
	defer trainingMutex.Unlock()

	if !trainingInProgress || currentCmd == nil {
		c.String(http.StatusBadRequest, "No training session to stop.")
		return
	}

	if err := currentCmd.Process.Kill(); err != nil {
		c.String(http.StatusInternalServerError, "Failed to stop the script: %v", err)
		return
	}

	trainingInProgress = false
	c.String(http.StatusOK, "Training session stopped.")
}

func runScript(c *gin.Context) {
	trainingMutex.Lock()
	defer trainingMutex.Unlock()

	if trainingInProgress {
		c.String(http.StatusBadRequest, "Training is already in progress.")
		return
	}

	// Parse the form data
	huggingfaceApiKey := c.PostForm("huggingface_api")

	// Config file
	configFile, err := c.FormFile("config_file")
	if err != nil {
		c.String(http.StatusBadRequest, "Config file is required.")
		return
	}

	// Save uploaded files
	knowledgeFile, knowledgeErr := c.FormFile("knowledge_file")
	skillsFile, skillsErr := c.FormFile("skills_file")

	if knowledgeErr != nil && skillsErr != nil {
		c.String(http.StatusBadRequest, "Either knowledge training file or skills training file is required.")
		return
	}

	// Delete previous /tmp/config.yaml, /tmp/knowledge_train.jsonl, /tmp/skills_train.jsonl files so we make sure
	// we have a COMPLETELY clean slate.
	os.Remove("/tmp/config.yaml")
	os.Remove("/tmp/knowledge_train.jsonl")
	os.Remove("/tmp/skills_train.jsonl")

	// Save the files to /tmp
	if knowledgeErr == nil {
		if err := c.SaveUploadedFile(knowledgeFile, "/tmp/knowledge_train.jsonl"); err != nil {
			c.String(http.StatusInternalServerError, "Failed to save knowledge training file: %v", err)
			return
		}
	}
	if skillsErr == nil {
		if err := c.SaveUploadedFile(skillsFile, "/tmp/skills_train.jsonl"); err != nil {
			c.String(http.StatusInternalServerError, "Failed to save skills training file: %v", err)
			return
		}
	}
	if err := c.SaveUploadedFile(configFile, "/tmp/config.yaml"); err != nil {
		c.String(http.StatusInternalServerError, "Failed to save config file: %v", err)
		return
	}

	// Open the log file for writing
	logFile, err := os.OpenFile(logFilePath, os.O_CREATE|os.O_WRONLY|os.O_TRUNC, 0644)
	if err != nil {
		c.String(http.StatusInternalServerError, "Failed to create log file: %v", err)
		return
	}
	defer logFile.Close()

	trainingInProgress = true
	currentCmd = exec.Command("bash", "./scripts/script.sh")
	// Check host running this binary if $HF_TOKEN is available. if huggingfaceApiKey is empty, use the one from the host
	if huggingfaceApiKey != "" {
		currentCmd.Env = append(os.Environ(), "HF_TOKEN="+huggingfaceApiKey)
	} else {
		currentCmd.Env = os.Environ()
	}

	stdout, err := currentCmd.StdoutPipe()
	if err != nil {
		c.String(http.StatusInternalServerError, "Failed to get stdout pipe: %v", err)
		return
	}
	stderr, err := currentCmd.StderrPipe()
	if err != nil {
		c.String(http.StatusInternalServerError, "Failed to get stderr pipe: %v", err)
		return
	}

	// Stream logs from stdout and stderr
	go streamLogs(stdout, logFilePath)
	go streamLogs(stderr, logFilePath)

	go func() {

		// Always defer trainingInProgress is set to false after training is done.
		// to ENSURE that it is set to false even if the script fails.
		defer func() {
			trainingMutex.Lock()
			trainingInProgress = false
			trainingMutex.Unlock()
		}()

		// Run the command
		if err := currentCmd.Start(); err != nil {
			log.Printf("Failed to start script: %v\n", err)
		}
		if err := currentCmd.Wait(); err != nil {
			log.Printf("Script execution error: %v\n", err)
		}

		log.Printf("Script execution finished.")
	}()

	c.String(http.StatusOK, "Script started.")
}

func streamLogs(pipe io.ReadCloser, logFilePath string) {
	logFile, err := os.OpenFile(logFilePath, os.O_WRONLY|os.O_APPEND, 0644)
	if err != nil {
		log.Printf("Failed to open log file: %v\n", err)
		return
	}
	defer logFile.Close()
	defer pipe.Close()

	scanner := bufio.NewScanner(pipe)
	for scanner.Scan() {
		line := scanner.Text()
		logMutex.Lock()
		_, err := logFile.WriteString(line + "\n")
		if err != nil {
			log.Printf("Failed to write to log file: %v\n", err)
		}
		logFile.Sync() // Ensure the log file is updated immediately
		logMutex.Unlock()
	}

	if err := scanner.Err(); err != nil {
		log.Printf("Error reading pipe: %v\n", err)
	}
}

func getTrainingState(c *gin.Context) {

	c.JSON(http.StatusOK, gin.H{
		"in_progress": trainingInProgress,
	})
}

func listFiles(c *gin.Context) {
	finalDir := "./final"
	fileLinks, err := getFileLinks(finalDir, "/final")
	if err != nil {
		c.String(http.StatusInternalServerError, "Error listing files: %v", err)
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"files": fileLinks,
	})
}

func getFileLinks(baseDir string, basePath string) ([]string, error) {
	var fileLinks []string

	files, err := os.ReadDir(baseDir)
	if err != nil {
		return nil, fmt.Errorf("failed to read directory %s: %v", baseDir, err)
	}

	for _, file := range files {
		if file.IsDir() {
			subDir := baseDir + "/" + file.Name()
			subPath := basePath + "/" + file.Name()
			subFileLinks, err := getFileLinks(subDir, subPath)
			if err != nil {
				return nil, fmt.Errorf("failed to read subdirectory %s: %v", subDir, err)
			}
			fileLinks = append(fileLinks, subFileLinks...)
		} else if file.Name() != "" {
			fileLinks = append(fileLinks, basePath+"/"+file.Name())
		}
	}

	return fileLinks, nil
}

func gatherSystemInfo() map[string]string {
	info := map[string]string{
		"gpu":  "undetectable",
		"vram": "undetectable",
		"cpu":  "undetectable",
		"ram":  "undetectable",
	}

	// Detect GPU and VRAM using `nvidia-smi`
	nvidiaCmd := exec.Command("nvidia-smi", "--query-gpu=gpu_name", "--format=csv,noheader,nounits")
	output, err := nvidiaCmd.Output()
	if err == nil {
		lines := strings.Split(strings.TrimSpace(string(output)), "\n")
		if len(lines) > 0 {
			gpuCount := make(map[string]int)
			for _, line := range lines {
				gpuCount[line]++
			}
			var gpuNames []string
			for name, count := range gpuCount {
				if count > 1 {
					gpuNames = append(gpuNames, fmt.Sprintf("%dx %s", count, name))
				} else {
					gpuNames = append(gpuNames, name)
				}
			}
			info["gpu"] = strings.Join(gpuNames, ", ")
		}
	}

	vramCmd := exec.Command("nvidia-smi", "--query-gpu=memory.total", "--format=csv,noheader,nounits")
	vramOutput, err := vramCmd.Output()
	if err == nil {
		lines := strings.Split(strings.TrimSpace(string(vramOutput)), "\n")
		if len(lines) > 0 {
			totalVRAM := calculateTotalVRAM(lines)
			info["vram"] = strings.TrimRight(strings.TrimRight(fmt.Sprintf("%.2f", float64(totalVRAM)/1024), "0"), ".")
		}
	}

	// Detect CPU using `lscpu`
	cpuCmd := exec.Command("lscpu")
	cpuOutput, err := cpuCmd.Output()
	if err == nil {
		scanner := bufio.NewScanner(strings.NewReader(string(cpuOutput)))
		for scanner.Scan() {
			line := scanner.Text()
			if strings.HasPrefix(line, "Model name:") {
				info["cpu"] = strings.TrimSpace(strings.Split(line, ":")[1])
				break
			}
		}
	}

	// Detect RAM using `free`
	freeCmd := exec.Command("free", "-g")
	freeOutput, err := freeCmd.Output()
	if err == nil {
		scanner := bufio.NewScanner(strings.NewReader(string(freeOutput)))
		for scanner.Scan() {
			line := scanner.Text()
			if strings.Contains(line, "Mem:") {
				parts := strings.Fields(line)
				if len(parts) > 1 {
					info["ram"] = parts[1] // Total memory
				}
				break
			}
		}
	}

	return info
}

func calculateTotalVRAM(lines []string) int {
	totalVRAM := 0
	for _, line := range lines {
		var vram int
		fmt.Sscanf(line, "%d", &vram)
		totalVRAM += vram
	}
	return totalVRAM
}

func getSystemInfo(c *gin.Context) {
	c.JSON(http.StatusOK, systemInfo)
}

func updateGPUUsageDataPeriodically() {
	for {
		updateGPUUsageData()
		time.Sleep(3 * time.Second)
	}
}

func updateGPUUsageData() {
	data := make(map[string]map[string]string)

	// Run nvidia-smi command to get GPU names
	nameCmd := exec.Command("nvidia-smi", "--query-gpu=index,gpu_name", "--format=csv,noheader,nounits")
	nameOutput, err := nameCmd.Output()
	if err == nil {
		lines := strings.Split(strings.TrimSpace(string(nameOutput)), "\n")
		for _, line := range lines {
			parts := strings.Split(line, ", ")
			if len(parts) == 2 {
				index := parts[0]
				name := parts[1]
				if data[index] == nil {
					data[index] = make(map[string]string)
				}
				data[index]["name"] = name
			}
		}
	}

	// Run nvidia-smi command for memory usage
	memoryCmd := exec.Command("nvidia-smi", "--query-gpu=index,memory.used,memory.total", "--format=csv,noheader,nounits")
	memoryOutput, err := memoryCmd.Output()
	if err == nil {
		lines := strings.Split(strings.TrimSpace(string(memoryOutput)), "\n")
		for _, line := range lines {
			parts := strings.Split(line, ", ")
			if len(parts) == 3 {
				index := parts[0]
				used := parts[1]
				total := parts[2]
				if data[index] == nil {
					data[index] = make(map[string]string)
				}
				data[index]["memory_used"] = used
				data[index]["memory_total"] = total
			}
		}
	}

	// Run nvidia-smi command for GPU utilization
	utilCmd := exec.Command("nvidia-smi", "--query-gpu=index,utilization.gpu", "--format=csv,noheader,nounits")
	utilOutput, err := utilCmd.Output()
	if err == nil {
		lines := strings.Split(strings.TrimSpace(string(utilOutput)), "\n")
		for _, line := range lines {
			parts := strings.Split(line, ", ")
			if len(parts) == 2 {
				index := parts[0]
				utilization := parts[1]
				if data[index] == nil {
					data[index] = make(map[string]string)
				}
				data[index]["utilization"] = utilization
			}
		}
	}

	dataMutex.Lock()
	gpuUsageData = data
	dataMutex.Unlock()
}

func getGPUUsage(c *gin.Context) {
	dataMutex.Lock()
	defer dataMutex.Unlock()

	c.JSON(http.StatusOK, gpuUsageData)
}
