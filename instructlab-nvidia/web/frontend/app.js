let trainingInProgress = false;
let fileStatus = { config: false, knowledge: false, skills: false };
let uploadedFiles = new Map();

document.addEventListener("DOMContentLoaded", () => {
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

  // Initial woof text
  document.getElementById("woof").textContent = "Woof! Get started by uploading your files.";
});

function fetchState() {
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
        link.href = file;
        link.textContent = file.replace("/final-files/", "");
        link.target = "_blank";
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
    woofElement.textContent = "Multi-phase training detected. I need at least 130GB of VRAM, hope you have a beefy GPU!";
  } else if (fileStatus.knowledge || fileStatus.skills) {
    woofElement.textContent = "Single-phase training detected. I need at least 48GB of VRAM, have 2x 4090's?";
  } else if (fileStatus.config) {
    woofElement.textContent = "Great! Got your config.yaml, now upload knowledge.jsonl or skills.jsonl.";
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
    alert("Config file and at least one of knowledge or skills files must be uploaded.");
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

  fetch("/run", {
    method: "POST",
    body: formData,
  })
    .then((res) => {
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
      document.getElementById("woof").textContent = "Training was manually stopped! Try again?"; // Reset woof text
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
    woofElement.textContent = "Training stopped! Your logs and files are located at the bottom of the page.";
  }

}

function fetchLogs() {
  const logDiv = document.getElementById("logs");

  const isScrolledToBottom = logDiv.scrollHeight - logDiv.clientHeight <= logDiv.scrollTop + 1;

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
        <p>GPU(s): ${data.gpu} <br>VRAM: ${data.vram} GB <br>CPU: ${data.cpu} <br>RAM: ${data.ram} GB</p>
      `;
      // If GPU is not "undetectable", change woof to say. "I can see your GPU! Nice ${data.gpu}!"
      if (data.gpu !== "undetectable") {
        document.getElementById("woof").textContent = `I can see your GPU! Nice ${data.gpu} with ${data.vram}GB of VRAM!`;
      }

      // If less than 48GB total VRAM, change woof to say. "I see you have ${data.gpu}, with a total of ${data.vram} VRAM. I need at least 48GB of VRAM to train well!"
      if (data.vram < 48 && data.gpu !== "undetectable") {
        document.getElementById("woof").textContent = `I see you have ${data.gpu}, with a total of ${data.vram}GB VRAM. I need at least 48GB of VRAM to train well!`;
      }
    })
    .catch((err) => {
      console.error("Failed to fetch system info:", err);
      document.getElementById("system-info").innerHTML =
        "<p>Unable to fetch system information.</p>";
    });
}