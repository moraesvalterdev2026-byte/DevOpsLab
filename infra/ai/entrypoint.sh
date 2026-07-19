#!/bin/bash
set -euo pipefail

COLOR_RED='\033[0;31m'
COLOR_RESET='\033[0m'

log_message() {
    echo -e "$(date '+%Y-%m-%d %H:%M:%S') - [AI Agent Bootstrap] $1"
}

validate_credentials() {
    log_message "Validating IAM credentials..."
    if [ -z "${IAM_USER:-}" ] || [ -z "${IAM_TOKEN:-}" ]; then
        echo -e "${COLOR_RED}ERRO: As variáveis de ambiente IAM_USER e IAM_TOKEN devem ser definidas e não podem estar vazias.${COLOR_RESET}"
        exit 1
    fi
    log_message "Credentials validated successfully."
}

# --- Execução Principal ---
validate_credentials

log_message "Iniciando o servidor Ollama..."
ollama serve &
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
