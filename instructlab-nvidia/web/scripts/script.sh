#!/bin/bash
set -e

# Completely remove /usr/local/cuda/compat from $LD_LIBRARY_PATH, export it then remove /usr/local/cuda/compat
# Prevent driver conflicts due to nvidia-container-toolkit
export LD_LIBRARY_PATH=$(echo $LD_LIBRARY_PATH | sed 's|/usr/local/cuda/compat:||g')

mkdir output final || true
GIT_REPO_NAME=$(echo $GIT_REPO | awk -F/ '{print $NF}')
OUTPUT_FOLDER_NAME=$GIT_REPO_NAME-$(date +%Y%m%d%H%M%S)
mkdir output/$OUTPUT_FOLDER_NAME || true

# Git clone from ARG in container to /workspace folder
git clone $GIT_REPO $OUTPUT_FOLDER_NAME

# Copy the config file over / overriding the current one
ilab config init --config $OUTPUT_FOLDER_NAME/config.yaml --taxonomy-path $OUTPUT_FOLDER_NAME --non-interactive

# Expecting files to be uploaded via UI for training
KNOWLEDGE_TRAIN_FILE="/tmp/knowledge_train.jsonl"
SKILLS_TRAIN_FILE="/tmp/skills_train.jsonl"

# Check if the required training files exist
if [[ ! -f "$KNOWLEDGE_TRAIN_FILE" ]] || [[ ! -f "$SKILLS_TRAIN_FILE" ]]; then
    echo "Error: Required training files (knowledge_train.jsonl or skills_train.jsonl) are missing."
    exit 1
fi

echo "Knowledge Train File: $KNOWLEDGE_TRAIN_FILE"
echo "Skills Train File: $SKILLS_TRAIN_FILE"

# Train using provided files
ilab train --data-output-dir output/$OUTPUT_FOLDER_NAME --strategy lab-multiphase \
    --phased-phase1-data $KNOWLEDGE_TRAIN_FILE --phased-phase2-data $SKILLS_TRAIN_FILE \
    --model-path .cache/instructlab/models/instructlab/granite-7b-lab \
    --device cuda --pipeline accelerated -y

mkdir output/$OUTPUT_FOLDER_NAME/models || true
cp /tmp/knowledge_train.jsonl output/$OUTPUT_FOLDER_NAME/models/knowledge_train.jsonl
cp /tmp/skills_train.jsonl output/$OUTPUT_FOLDER_NAME/models/skills_train.jsonl
# Package the final model
tar -czvf final/$GIT_REPO_NAME-trained-model-$(date +%Y%m%d%H%M%S).tar.gz output/$OUTPUT_FOLDER_NAME
