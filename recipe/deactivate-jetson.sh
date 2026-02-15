#!/bin/bash
# Ollama Jetson environment deactivation script

unset OLLAMA_HOST
unset OLLAMA_MODELS
unset OLLAMA_LOGS
unset OLLAMA_LLM_LIBRARY

# Restore previous LD_LIBRARY_PATH
if [ -n "${_OLLAMA_OLD_LD_LIBRARY_PATH:-}" ]; then
    export LD_LIBRARY_PATH="${_OLLAMA_OLD_LD_LIBRARY_PATH}"
else
    unset LD_LIBRARY_PATH
fi
unset _OLLAMA_OLD_LD_LIBRARY_PATH
