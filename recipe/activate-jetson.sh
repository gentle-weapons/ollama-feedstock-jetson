#!/bin/bash
# Ollama Jetson environment activation script
# Installed by the ollama conda package for JetPack variants

# Listen on all interfaces (needed for remote access / Open WebUI)
export OLLAMA_HOST="${OLLAMA_HOST:-0.0.0.0:11434}"

# Store models inside the conda environment by default
export OLLAMA_MODELS="${OLLAMA_MODELS:-${CONDA_PREFIX}/share/ollama/models}"

# Log file location
export OLLAMA_LOGS="${OLLAMA_LOGS:-${CONDA_PREFIX}/var/log/ollama.log}"

# Select the correct CUDA library for the JetPack build
export OLLAMA_LLM_LIBRARY="${OLLAMA_LLM_LIBRARY:-cuda_v12}"
