#!/bin/bash
set -euo pipefail

log_message() {
    echo -e "$(date '+%Y-%m-%d %H:%M:%S') - [AI Agent Bootstrap] $1"
}

log_message "Iniciando o servidor Ollama..."
/bin/ollama serve &
OLLAMA_PID=$!

log_message "Aguardando o serviço Ollama iniciar..."
# We use 'ollama ps' as a native health check to avoid external dependencies
# like curl or wget, which may not exist in the base image.
until ollama ps > /dev/null 2>&1; do
    sleep 2
done

log_message "Garantindo que o modelo 'gemma:2b' esteja disponível..."
ollama pull gemma:2b

wait $OLLAMA_PID
