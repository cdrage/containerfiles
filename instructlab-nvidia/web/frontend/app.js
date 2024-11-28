let trainingInProgress = false;
let fileStatus = { config: false, knowledge: false, skills: false };

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

    fileInput.addEventListener("change", (event) => handleFiles(event.target.files));

    document.getElementById("run").addEventListener("click", startTraining);
    document.getElementById("stop").addEventListener("click", stopTraining);

    fetchLogs();
    setInterval(fetchLogs, 2000);
});

function handleFiles(files) {
    Array.from(files).forEach((file) => {
        if (file.name.endsWith(".yaml") && !fileStatus.config) {
            fileStatus.config = true;
            updateStatus("config", true);
        } else if (file.name.includes("knowledge") && file.name.endsWith(".jsonl") && !fileStatus.knowledge) {
            fileStatus.knowledge = true;
            updateStatus("knowledge", true);
        } else if (file.name.includes("skills") && file.name.endsWith(".jsonl") && !fileStatus.skills) {
            fileStatus.skills = true;
            updateStatus("skills", true);
        }
    });
}

function updateStatus(type, status) {
    const statusIndicator = document.getElementById(`${type}-status`);
    statusIndicator.textContent = status ? "✅" : "❌";
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

    trainingInProgress = true;
    updateUI();

    // Start training simulation
    console.log("Training started...");
}

function stopTraining() {
    trainingInProgress = false;
    updateUI();
    console.log("Training stopped.");
}

function updateUI() {
    document.getElementById("run").disabled = trainingInProgress;
    document.getElementById("stop").disabled = !trainingInProgress;

    // Toggle visibility of form-group, file-drop-area, and file-status
    const elementsToToggle = ["form-group", "file-drop-area", "file-status"];
    elementsToToggle.forEach(id => {
        const element = document.querySelector(`.${id}`); // Adjusted to match class names
        if (element) {
            element.style.display = trainingInProgress ? "none" : "block";
        }
    });
}

function fetchLogs() {
    const logDiv = document.getElementById("logs");
    const isScrolledToBottom = logDiv.scrollHeight - logDiv.clientHeight <= logDiv.scrollTop + 1;

    if (isScrolledToBottom) {
        logDiv.scrollTop = logDiv.scrollHeight;
    }
}
