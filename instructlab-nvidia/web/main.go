package main

import (
	"bufio"
	"io"
	"log"
	"net/http"
	"os"
	"os/exec"
	"sync"

	"github.com/gin-gonic/gin"
)

var (
	logMutex           sync.Mutex
	logFilePath        = "logs/script.log"
	currentCmd         *exec.Cmd
	trainingInProgress bool
	trainingMutex      sync.Mutex
)

func main() {
	// Ensure logs directory exists
	if err := os.MkdirAll("logs", 0755); err != nil {
		log.Fatalf("Failed to create logs directory: %v", err)
	}

	// Setup router
	r := gin.Default()
	r.Static("/static", "./frontend")
	r.GET("/logs", getLogs)
	r.GET("/state", getTrainingState)
	r.POST("/run", runScript)
	r.POST("/stop", stopScript)
	r.Static("/final-files", "./final")
	r.GET("/files", listFiles)

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
	knowledgeFile, err := c.FormFile("knowledge_file")
	if err != nil {
		c.String(http.StatusBadRequest, "Knowledge training file is required.")
		return
	}

	skillsFile, err := c.FormFile("skills_file")
	if err != nil {
		c.String(http.StatusBadRequest, "Skills training file is required.")
		return
	}

	// Save the files to /tmp
	if err := c.SaveUploadedFile(knowledgeFile, "/tmp/knowledge_train.jsonl"); err != nil {
		c.String(http.StatusInternalServerError, "Failed to save knowledge training file: %v", err)
		return
	}
	if err := c.SaveUploadedFile(skillsFile, "/tmp/skills_train.jsonl"); err != nil {
		c.String(http.StatusInternalServerError, "Failed to save skills training file: %v", err)
		return
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
		// Run the command
		if err := currentCmd.Start(); err != nil {
			log.Printf("Failed to start script: %v\n", err)
		}
		if err := currentCmd.Wait(); err != nil {
			log.Printf("Script execution error: %v\n", err)
		}

		// Mark training as finished
		trainingMutex.Lock()
		trainingInProgress = false
		trainingMutex.Unlock()

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
	trainingMutex.Lock()
	defer trainingMutex.Unlock()

	c.JSON(http.StatusOK, gin.H{
		"in_progress": trainingInProgress,
	})
}

func listFiles(c *gin.Context) {
	finalDir := "./final"
	files, err := os.ReadDir(finalDir)
	if err != nil {
		c.String(http.StatusInternalServerError, "Failed to read final directory: %v", err)
		return
	}

	var fileLinks []string
	for _, file := range files {
		if !file.IsDir() && file.Name() != "" {
			fileLinks = append(fileLinks, "/final-files/"+file.Name()) // Updated route
		}
	}

	c.JSON(http.StatusOK, gin.H{
		"files": fileLinks,
	})
}
