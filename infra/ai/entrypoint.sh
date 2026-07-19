#!/bin/bash
set -euo pipefail

COLOR_RED='\033[0;31m'
COLOR_YELLOW='\033[1;33m'
COLOR_GREEN='\033[0;32m'
COLOR_RESET='\033[0m'

log_message() {
    echo -e "$(date '+%Y-%m-%d %H:%M:%S') - [AI Agent Bootstrap] $1"
}

validate_credentials() {
    log_message "Validando credenciais IAM..."
    if [ -z "${IAM_USER:-}" ] || [ -z "${IAM_TOKEN:-}" ]; then
        echo -e "${COLOR_RED}ERRO: As variáveis de ambiente IAM_USER e IAM_TOKEN devem ser definidas.${COLOR_RESET}"
        exit 1
    fi
    log_message "Credenciais validadas com sucesso."
}

start_ollama() {
    log_message "Iniciando o servidor Ollama..."
    ollama serve &
    OLLAMA_PID=$!

    log_message "Aguardando o serviço Ollama iniciar (pode demorar em máquinas com pouca memória)..."
    local retries=30
    local count=0
    until ollama ps > /dev/null 2>&1; do
        count=$((count+1))
        if [ "$count" -ge "$retries" ]; then
            echo -e "${COLOR_YELLOW}Aviso: Ollama não respondeu após ${retries} tentativas. Continuando mesmo assim.${COLOR_RESET}"
            break
        fi
        sleep 5
    done

    log_message "Garantindo que o modelo '${LLM_MODEL:-gemma:2b}' esteja disponível..."
    ollama pull "${LLM_MODEL:-gemma:2b}" || {
        echo -e "${COLOR_YELLOW}Aviso: não foi possível baixar o modelo agora. Você pode tentar manualmente depois.${COLOR_RESET}"
    }

    wait $OLLAMA_PID
}

# --- Execução Principal ---
validate_credentials
start_ollama
