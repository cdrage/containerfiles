#!/bin/bash

# Completely remove /usr/local/cuda/compat from $LD_LIBRARY_PATH, export it then remove /usr/local/cuda/compat
# Why? Because we are running this in nvidia-container-toolkit, the drivers can get confused if they see the compat directory
# since it'll be different versions sometimes vs the host.
export LD_LIBRARY_PATH=$(echo $LD_LIBRARY_PATH | sed 's|/usr/local/cuda/compat:||g')

# Make directories
mkdir -p /output/generated_data
mkdir -p /output/trained_model

# Git clone from ARG in container to /workspace folder
git clone $GIT_REPO workspace

# Remove any previous configurations
rm -rf ~/.config/instructlab

# Copy the config file over / overriding the current one
ilab config init --config workspace/config.yaml --taxonomy-path workspace --non-interactive

# Run the synthetic data generation command
ilab data generate --taxonomy-base empty --output-dir /output/generated_data

# Find what file starts with train_* and use that
TRAIN_FILE=$(find /output/generated_data -type f -name "train_*" | head -n 1)

# Train
# TODO: Specify the ACTUAL model you want to train with...
# training can be done on any model I believe.
ilab train --data-path /output/generated_data --data-output-dir $(echo $TRAIN_FILE) --model-path ~/.cache/instructlab/models/instructlab/granite-7b-lab --device cuda

# Convert to GGUF?
ilab model convert --model-dir /output/trained_model