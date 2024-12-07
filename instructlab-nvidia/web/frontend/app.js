let trainingInProgress = false;
let loadingTraining = false;
let fileStatus = { config: false, knowledge: false, skills: false };
let uploadedFiles = new Map();

document.addEventListener("DOMContentLoaded", () => {
  const tabButtons = document.querySelectorAll('.tab-button');
    const tabContents = document.querySelectorAll('.tab-content');

    tabButtons.forEach(button => {
        button.addEventListener('click', () => {
            // Remove active class from all buttons
            tabButtons.forEach(btn => btn.classList.remove('active'));
            // Add active class to clicked button
            button.classList.add('active');

            // Hide all tab contents
            tabContents.forEach(content => content.classList.add('hidden'));
            // Show the selected tab content
            const tabId = button.getAttribute('data-tab') + '-tab';
            document.getElementById(tabId).classList.remove('hidden');
        });
    });

  fetchSystemInfo();

  const fileDropArea = document.getElementById("file-drop-area");
  const fileInput = document.getElementById("file-upload");

  fileDropArea.addEventListener("dragover", (event) => {
    event.preventDefault();
    fileDropArea.classList.add("drag-over");
  });

  fileDropArea.addEventListener("dragleave", () => {
    fileDropArea.classList.remove("drag-over");
  });

  fileDropArea.addEventListener("drop", (event) => {
    event.preventDefault();
    fileDropArea.classList.remove("drag-over");
    handleFiles(event.dataTransfer.files);
  });

  fileDropArea.addEventListener("click", () => fileInput.click());

  fileInput.addEventListener("change", (event) =>
    handleFiles(event.target.files)
  );

  document.getElementById("run").addEventListener("click", startTraining);
  document.getElementById("stop").addEventListener("click", stopTraining);

  fetchState(); // Initial state fetch
  setInterval(fetchState, 1000); // Poll state every second, we want this shown as quick as possible

  fetchLogs();
  setInterval(fetchLogs, 2000);

  fetchFiles();
  setInterval(fetchFiles, 2000);

  fetchGPUInfo();
  setInterval(fetchGPUInfo, 3000);

  // Initial woof text
  document.getElementById("woof").textContent =
    "Arf! Let's start fine tuning!";
});

function fetchState() {
  if (loadingTraining) {
    return;
  }
  fetch("/state")
    .then((res) => res.json())
    .then((data) => {
      if (data.in_progress !== trainingInProgress) {
        trainingInProgress = data.in_progress;
        updateUI(); // Update the UI only if the state changes
      }
    })
    .catch((err) => console.error("Failed to fetch state:", err));
}

function fetchFiles() {
  fetch("/files")
    .then((res) => res.json())
    .then((data) => {
      const fileList = document.getElementById("file-list");
      fileList.innerHTML = "";

      data.files.forEach((file) => {
        const listItem = document.createElement("li");
        const link = document.createElement("a");
        const fileName = file.split("/").pop(); // Extract the file name
        link.href = file;
        link.textContent = file.replace("/final/", ""); // Show the path without "/final/"
        link.download = fileName; // Set the download attribute to just the file name
        listItem.appendChild(link);
        fileList.appendChild(listItem);
      });
    })
    .catch((err) => console.error("Failed to fetch files:", err));
}

function handleFiles(files) {
  let knowledgeUploaded = false;
  let skillsUploaded = false;

  Array.from(files).forEach((file) => {
    if (file.name.endsWith(".yaml") && !uploadedFiles.has("config")) {
      uploadedFiles.set("config", file);
      fileStatus.config = true;
      updateStatus("config", true);
    } else if (
      file.name.includes("knowledge") &&
      file.name.endsWith(".jsonl") &&
      !uploadedFiles.has("knowledge")
    ) {
      uploadedFiles.set("knowledge", file);
      fileStatus.knowledge = true;
      updateStatus("knowledge", true);
      knowledgeUploaded = true;
    } else if (
      file.name.includes("skills") &&
      file.name.endsWith(".jsonl") &&
      !uploadedFiles.has("skills")
    ) {
      uploadedFiles.set("skills", file);
      fileStatus.skills = true;
      updateStatus("skills", true);
      skillsUploaded = true;
    }
  });

  updateWoofText(knowledgeUploaded, skillsUploaded);
}

function updateWoofText(knowledge, skills) {
  const woofElement = document.getElementById("woof");

  if (fileStatus.knowledge && fileStatus.skills) {
    woofElement.textContent =
      "Multi-phase training detected. I need at least 120GB of VRAM";
  } else if (fileStatus.knowledge || fileStatus.skills) {
    woofElement.textContent =
      "Single-phase training detected. I need at least 96GB of VRAM";
  } else if (fileStatus.config) {
    woofElement.textContent =
      "Great! Got your config.yaml, now upload knowledge.jsonl or skills.jsonl.";
  }
}

function updateStatus(type, status) {
  const statusIndicator = document.getElementById(`${type}-status`);
  statusIndicator.textContent = status ? "O" : "X";
  statusIndicator.style.color = status ? "green" : "red";
  statusIndicator.style.border = status ? "2px solid green" : "2px solid red";
}

function startTraining() {
  if (trainingInProgress) {
    alert("Training is already in progress.");
    return;
  }

  if (!fileStatus.config || (!fileStatus.knowledge && !fileStatus.skills)) {
    alert(
      "Config file and at least one of knowledge or skills files must be uploaded."
    );
    return;
  }
  trainingInProgress = true;
  updateUI();

  const huggingfaceApi = document.getElementById("huggingface-api").value;

  const formData = new FormData();
  formData.append("huggingface_api", huggingfaceApi);

  // Append files from uploadedFiles
  uploadedFiles.forEach((file, key) => {
    const fieldName = `${key}_file`;
    formData.append(fieldName, file);
  });

  updateUI();

  // Set loadingTraining to true to prevent the UI from updating the training status
  loadingTraining = true;
  fetch("/run", {
    method: "POST",
    body: formData,
  })
    .then((res) => {
      loadingTraining = false;
      if (!res.ok) {
        throw new Error("Failed to start training.");
      }
      return res.text();
    })
    .then((msg) => {
      console.log("Training started:", msg);
    })
    .catch((err) => {
      console.error("This is the error: ", err);
      alert(
        "An error occurred while starting the training. Please check the logs."
      );
      trainingInProgress = false;
      loadingTraining = false;
      updateUI();
    });
}

function stopTraining() {
  const userConfirmed = confirm("Are you sure you want to stop the training?");

  if (!userConfirmed) {
    return; // Exit if the user cancels
  }

  fetch("/stop", { method: "POST" })
    .then((res) => res.text())
    .then((msg) => {
      trainingInProgress = false;
      updateUI();
      document.getElementById("woof").textContent =
        "Training was manually stopped! Try again?"; // Reset woof text
      console.log(msg);
    })
    .catch((err) => console.error(err));
}

function updateUI() {
  document.getElementById("run").disabled = trainingInProgress;
  document.getElementById("stop").disabled = !trainingInProgress;

  const elementsToToggle = ["form-group", "file-drop-area", "file-status"];
  elementsToToggle.forEach((className) => {
    const element = document.querySelector(`.${className}`);
    if (element) {
      element.style.display = trainingInProgress ? "none" : "block";
    }
  });

  const woofElement = document.getElementById("woof");
  if (trainingInProgress) {
    woofElement.textContent = "Arf! Training in progress... Get that coffee!";
  } else {
    woofElement.textContent =
      "Training stopped! Your logs and files are located at the bottom of the page.";
  }
}

function fetchLogs() {
  const logDiv = document.getElementById("logs");

  const isScrolledToBottom =
    logDiv.scrollHeight - logDiv.clientHeight <= logDiv.scrollTop + 1;

  fetch("/logs")
    .then((res) => res.json())
    .then((logs) => {
      logDiv.innerHTML = logs.map((line) => `<p>${line}</p>`).join("");

      if (isScrolledToBottom) {
        logDiv.scrollTop = logDiv.scrollHeight;
      }
    })
    .catch((err) => console.error(err));
}

function fetchSystemInfo() {
  fetch("/system-info")
    .then((res) => res.json())
    .then((data) => {
      const systemInfoDiv = document.getElementById("system-info");
      systemInfoDiv.innerHTML = `
        <p>GPU(s): ${data.gpu} <br>TOTAL VRAM: ${data.vram} GB <br>CPU: ${data.cpu} <br>RAM: ${data.ram} GB</p>
      `;
      // If GPU is not "undetectable", change woof to say. "I can see your GPU! Nice ${data.gpu}!"
      if (data.gpu !== "undetectable") {
        document.getElementById(
          "woof"
        ).textContent = `I can see your GPU! Nice ${data.gpu} with ${data.vram}GB of VRAM!`;
      }

      // Nothing will work well on accelerators with less than 96GB of VRAM
      // unfortunate, but necessary
      if (data.vram < 96 && data.gpu !== "undetectable") {
        document.getElementById(
          "woof"
        ).textContent = `I see you have ${data.gpu}, with a total of ${data.vram}GB VRAM. I need at least 96GB of VRAM to train well for single-phase training!`;
      }
    })
    .catch((err) => {
      console.error("Failed to fetch system info:", err);
      document.getElementById("system-info").innerHTML =
        "<p>Unable to fetch system information.</p>";
    });
}

function fetchGPUInfo() {

  // Fetch GPU usage info and update bars
  fetch("/gpu-usage")
    .then((res) => res.json())
    .then((data) => {
      const systemInfoDiv = document.getElementById("gpu-info");
      const gpuInfoDiv = document.createElement("div");

      Object.entries(data).forEach(([gpuIndex, gpuInfo]) => {
        const memoryUsed = parseInt(gpuInfo.memory_used, 10);
        const memoryTotal = parseInt(gpuInfo.memory_total, 10);
        const utilization = parseInt(gpuInfo.utilization, 10);

        const memoryPercentage = ((memoryUsed / memoryTotal) * 100).toFixed(2);

        // Create GPU info container
        const gpuContainer = document.createElement("div");
        gpuContainer.classList.add("gpu-container");

        // GPU name
        const gpuName = document.createElement("p");
        gpuName.textContent = `GPU ${gpuIndex}: ${gpuInfo.name}`;
        gpuContainer.appendChild(gpuName);

        // Memory bar
        const memoryBarContainer = document.createElement("div");
        memoryBarContainer.classList.add("bar-container");
        const memoryBar = document.createElement("div");
        memoryBar.classList.add("bar");
        memoryBar.style.width = `${memoryPercentage}%`;
        memoryBar.textContent = `${memoryUsed} MB / ${memoryTotal} MB (${memoryPercentage}%)`;
        memoryBarContainer.appendChild(memoryBar);
        gpuContainer.appendChild(memoryBarContainer);

        // Utilization bar
        const utilizationBarContainer = document.createElement("div");
        utilizationBarContainer.classList.add("bar-container");
        const utilizationBar = document.createElement("div");
        utilizationBar.classList.add("bar");
        utilizationBar.style.width = `${utilization}%`;
        utilizationBar.textContent = `${utilization}%`;
        utilizationBarContainer.appendChild(utilizationBar);
        gpuContainer.appendChild(utilizationBarContainer);

        gpuInfoDiv.appendChild(gpuContainer);
      });

      // Update the system info div with GPU info
      systemInfoDiv.innerHTML = gpuInfoDiv.innerHTML;
    })
    .catch((err) => {
      console.error("Failed to fetch GPU usage info:", err);
      document.getElementById("system-info").innerHTML =
        "<p>Unable to fetch GPU usage information.</p>";
    });
}