let trainingInProgress = false;
let fileStatus = { config: false, knowledge: false, skills: false };
let uploadedFiles = new Map();

document.addEventListener("DOMContentLoaded", () => {
  fetch("/state")
    .then((res) => res.json())
    .then((data) => {
      trainingInProgress = data.in_progress;
      updateUI();
    })
    .catch((err) => console.error(err));

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

  fetchLogs();
  setInterval(fetchLogs, 2000);
});

function handleFiles(files) {
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
    } else if (
      file.name.includes("skills") &&
      file.name.endsWith(".jsonl") &&
      !uploadedFiles.has("skills")
    ) {
      uploadedFiles.set("skills", file);
      fileStatus.skills = true;
      updateStatus("skills", true);
    }
  });
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

  if (!fileStatus.config || !fileStatus.knowledge || !fileStatus.skills) {
    alert("All required files must be uploaded.");
    return;
  }

  const huggingfaceApi = document.getElementById("huggingface-api").value;

  const formData = new FormData();
  formData.append("huggingface_api", huggingfaceApi);

  // Append files from uploadedFiles
  uploadedFiles.forEach((file, key) => {
    const fieldName = `${key}_file`;
    formData.append(fieldName, file);
  });

  trainingInProgress = true;
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
            console.log(msg);
        })
        .catch((err) => console.error(err));
  trainingInProgress = false;
  updateUI();
  console.log("Training stopped.");
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
}

function fetchLogs() {
    const logDiv = document.getElementById("logs");

    // Check if the user is at the bottom of the scroll
    const isScrolledToBottom = logDiv.scrollHeight - logDiv.clientHeight <= logDiv.scrollTop + 1;

    fetch("/logs")
        .then((res) => res.json())
        .then((logs) => {
            // Update the logs
            logDiv.innerHTML = logs.map((line) => `<p>${line}</p>`).join("");

            // If the user was at the bottom, keep them there
            if (isScrolledToBottom) {
                logDiv.scrollTop = logDiv.scrollHeight;
            }
        })
        .catch((err) => console.error(err));
}