#!/bin/bash
set -e


# get HF_TOKEN from host
HF_TOKEN=$HF_TOKEN
# Completely remove /usr/local/cuda/compat from $LD_LIBRARY_PATH, export it then remove /usr/local/cuda/compat
# Prevent driver conflicts due to nvidia-container-toolkit
export LD_LIBRARY_PATH=$(echo $LD_LIBRARY_PATH | sed 's|/usr/local/cuda/compat:||g')

# Expecting files to be uploaded via UI for training
KNOWLEDGE_TRAIN_FILE="/tmp/knowledge_train.jsonl"
SKILLS_TRAIN_FILE="/tmp/skills_train.jsonl"
CONFIG_FILE="/tmp/config.yaml"

# Within the /tmp/config.yaml there is train.model which is the model used for training
# Get the last two parts, for example: model: /opt/app-root/src/.cache/instructlab/models/instructlab/granite-7b-lab
# should show instructlab/granite-7b-lab
MODEL_PATH=$(/usr/bin/yq e '.train.model' "$CONFIG_FILE" | awk -F/ '{print $(NF-1)"/"$NF}')

# We use a "judge" model for MT-Bench evaluation too
PHASED_MT_BENCH_JUDGE=$(/usr/bin/yq e '.train.phased_mt_bench_judge' "$CONFIG_FILE" | awk -F/ '{print $(NF-1)"/"$NF}')

mkdir output final || true
GIT_REPO_NAME=$(echo $GIT_REPO | awk -F/ '{print $NF}')
OUTPUT_FOLDER_NAME=$GIT_REPO_NAME-$(date +%Y%m%d%H%M%S)
mkdir output/$OUTPUT_FOLDER_NAME || true

# Copy the config file over / overriding the current one
ilab config init --config $CONFIG_FILE --non-interactive

# Make sure that we download these models before training, these are the only important ones needed
# when this script is ran, we make sure that HUGGINGFACE_TOKEN (was) set
ilab model download -rp $PHASED_MT_BENCH_JUDGE --hf-token $HF_TOKEN
ilab model download -rp $MODEL_PATH --hf-token $HF_TOKEN

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
