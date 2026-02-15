#!/bin/bash
# Ollama Jetson environment activation script
# Installed by the ollama conda package for JetPack variants

# Listen on all interfaces (needed for remote access / Open WebUI)
export OLLAMA_HOST="${OLLAMA_HOST:-0.0.0.0:11434}"

# Store models inside the conda environment by default
export OLLAMA_MODELS="${OLLAMA_MODELS:-${CONDA_PREFIX}/share/ollama/models}"

# Log file location
export OLLAMA_LOGS="${OLLAMA_LOGS:-${CONDA_PREFIX}/var/log/ollama.log}"

# Tell ollama to use the JetPack CUDA runner (matches cuda_jetpack6/ directory name)
export OLLAMA_LLM_LIBRARY="${OLLAMA_LLM_LIBRARY:-cuda_jetpack6}"

# Make runner libraries discoverable by the dynamic linker
export _OLLAMA_OLD_LD_LIBRARY_PATH="${LD_LIBRARY_PATH:-}"
export LD_LIBRARY_PATH="${CONDA_PREFIX}/lib/ollama/cuda_jetpack6:${CONDA_PREFIX}/lib/ollama${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"
