#!/bin/bash
set -e

echo "Starting the training!"

# Completely remove /usr/local/cuda/compat from $LD_LIBRARY_PATH, export it then remove /usr/local/cuda/compat
# Prevent driver conflicts due to nvidia-container-toolkit on k8s when running this container.
export LD_LIBRARY_PATH=$(echo $LD_LIBRARY_PATH | sed 's|/usr/local/cuda/compat:||g')

# Expecting files to be uploaded via UI for training
KNOWLEDGE_TRAIN_FILE="/tmp/knowledge_train.jsonl"
SKILLS_TRAIN_FILE="/tmp/skills_train.jsonl"
CONFIG_FILE="/tmp/config.yaml"

# Check if knowledge OR skills training files exist
if [[ ! -f "$KNOWLEDGE_TRAIN_FILE" ]] && [[ ! -f "$SKILLS_TRAIN_FILE" ]]; then
    echo "No training files found! Exiting!"
    exit 1
fi

echo "Knowledge Train File: $KNOWLEDGE_TRAIN_FILE"
echo "Skills Train File: $SKILLS_TRAIN_FILE"

# TODO:
# Check with nvidia-smi how many GPUS there are, compare that to .train.nproc_per_node and put in BIG LETTERS AND EXPLANATION MARKS
# that the amount of gpus detected vs the config is incorrect.

# Within the /tmp/config.yaml there is train.model which is the model used for training
# Get the last two parts, for example: model: /opt/app-root/src/.cache/instructlab/models/instructlab/granite-7b-lab
# should show instructlab/granite-7b-lab
MODEL_PATH=$(/usr/bin/yq e '.train.model' "$CONFIG_FILE" | awk -F/ '{print $(NF-1)"/"$NF}')

# We use a "judge" model for MT-Bench evaluation too
PHASED_MT_BENCH_JUDGE=$(/usr/bin/yq e '.train.phased_mt_bench_judge' "$CONFIG_FILE" | awk -F/ '{print $(NF-1)"/"$NF}')

MULTI_PHASE=false
# If skills train file AND knowledge train file exist, we are going to use multi-phase, so create boolean
if [[ -f "$KNOWLEDGE_TRAIN_FILE" ]] && [[ -f "$SKILLS_TRAIN_FILE" ]]; then
    MULTI_PHASE=true
fi

# If we are multi-phase, announce it! Otherwise we will just be doing a single phase training
if [[ "$MULTI_PHASE" == true ]]; then
    echo "Multi-phase training detected! Make some coffee, this will take a while!"
else
    echo "Single-phase training detected! Let's get this done!"
fi

# Create some folders for the output
MODEL_TRAINING_NAME=$(echo $MODEL_PATH | awk -F/ '{print $NF}')
OUTPUT_FOLDER_NAME=$MODEL_TRAINING_NAME-$(date +%Y%m%d%H%M%S)

mkdir output final || true
mkdir output/$OUTPUT_FOLDER_NAME || true

# Copy the config file over / overriding the current one
ilab config init --config $CONFIG_FILE --non-interactive

# Make sure that we download these models before training, these are the only important ones needed
# when this script is ran, we make sure that HUGGINGFACE_TOKEN (was) set
echo "Going to download your model from your config file! Hopefully you have a Hugging Face token set / access!"
ilab model download -rp $MODEL_PATH --hf-token $HF_TOKEN

# If we are doing multi-phase, download the judge model, as that will be required for the evaluation
# of the model
if [[ "$MULTI_PHASE" == true ]]; then
    echo "Going to download the judge model for MT-Bench evaluation!"
    ilab model download -rp $PHASED_MT_BENCH_JUDGE --hf-token $HF_TOKEN
fi

# Create the final result and checkpoints folder
mkdir -p final/$OUTPUT_FOLDER_NAME/result || true
mkdir -p final/$OUTPUT_FOLDER_NAME/checkpoints || true

echo "Going to train with model $MODEL_PATH"

# If we are doing multi-phase, we will be using the lab-multiphase strategy
if [[ "$MULTI_PHASE" == true ]]; then
    echo "Starting the multi-phase training!"
    ilab train --data-output-dir final/$OUTPUT_FOLDER_NAME/result --ckpt-output-dir final/$OUTPUT_FOLDER_NAME/checkpoints \
        --strategy lab-multiphase \
        --phased-phase1-data $KNOWLEDGE_TRAIN_FILE --phased-phase2-data $SKILLS_TRAIN_FILE \
        --model-path /opt/app-root/src/.cache/instructlab/models/$MODEL_PATH \
        --device cuda --pipeline accelerated -y
else
    echo "Starting the single-phase training!"
    # For single-phase training, figure out if knowledge or skills train was uploaded
    if [[ -f "$KNOWLEDGE_TRAIN_FILE" ]]; then
        TRAIN_FILE=$KNOWLEDGE_TRAIN_FILE
    elif [[ -f "$SKILLS_TRAIN_FILE" ]]; then
        TRAIN_FILE=$SKILLS_TRAIN_FILE
    fi

    ilab train --data-output-dir final/$OUTPUT_FOLDER_NAME/result --ckpt-output-dir final/$OUTPUT_FOLDER_NAME/checkpoints \
        --data-path $TRAIN_FILE \
        --model-path /opt/app-root/src/.cache/instructlab/models/$MODEL_PATH \
        --device cuda --pipeline accelerated -y 
fi

# Package the final model (/result) folder
#tar -czvf final/$MODEL_TRAINING_NAME-trained-model-$(date +%Y%m%d%H%M%S).tar.gz final/$OUTPUT_FOLDER_NAME/result

echo "Done the training! See the below files on how to download as well as the above log to see which checkpoint is the best to use!"