let trainingInProgress = false;

document.addEventListener("DOMContentLoaded", () => {
    fetch("/state")
        .then((res) => res.json())
        .then((data) => {
            trainingInProgress = data.in_progress;
            updateUI();
        })
        .catch((err) => console.error(err));
});

document.getElementById("run").addEventListener("click", () => {
    if (trainingInProgress) {
        alert("Training is already in progress.");
        return;
    }

    const githubUrl = document.getElementById("github-url").value;
    const knowledgeFile = document.getElementById("knowledge-file").files[0];
    const skillsFile = document.getElementById("skills-file").files[0];

    if (!githubUrl) {
        alert("Please enter a GitHub URL.");
        return;
    }

    if (!knowledgeFile || !skillsFile) {
        alert("Please upload both knowledge and skills files.");
        return;
    }

    const formData = new FormData();
    formData.append("github_url", githubUrl);
    formData.append("knowledge_file", knowledgeFile);
    formData.append("skills_file", skillsFile);

    trainingInProgress = true;
    updateUI();

    fetch("/run", {
        method: "POST",
        body: formData,
    })
        .then((res) => res.text())
        .then((msg) => console.log(msg))
        .catch((err) => console.error(err));
});

document.getElementById("stop").addEventListener("click", () => {
    fetch("/stop", { method: "POST" })
        .then((res) => res.text())
        .then((msg) => {
            trainingInProgress = false;
            updateUI();
            console.log(msg);
        })
        .catch((err) => console.error(err));
});

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

// Poll logs every 2 seconds
setInterval(fetchLogs, 2000);

function updateUI() {
    document.getElementById("run").disabled = trainingInProgress;
    document.getElementById("stop").disabled = !trainingInProgress;
    document.getElementById("github-url").disabled = trainingInProgress;
}

fetchLogs();

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
                link.textContent = file.split("/").pop(); // Show only the file name
                link.target = "_blank"; // Open in new tab
                listItem.appendChild(link);
                fileList.appendChild(listItem);
            });
        })
        .catch((err) => console.error("Failed to fetch files:", err));
}

// Refresh file list every 10 seconds
setInterval(fetchFiles, 10000);

// Fetch files on page load
document.addEventListener("DOMContentLoaded", fetchFiles);
