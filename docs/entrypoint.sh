#!/bin/bash
#
# Entrypoint customizado para o container do Ollama (axes_ai_agent)
# Objetivo: Iniciar o serviço e garantir que os modelos de IA necessários
#           estejam disponíveis, automatizando o bootstrap do ambiente.
#
set -euo pipefail

# --- Cores e Funções de Log ---
COLOR_BLUE='\033[0;34m'
COLOR_RESET='\033[0m'

log_message() {
    echo -e "$(date '+%Y-%m-%d %H:%M:%S') - ${COLOR_BLUE}[AI Agent Bootstrap]${COLOR_RESET} $1"
}

# 1. Inicia o servidor Ollama em background
log_message "Iniciando o servidor Ollama..."
/bin/ollama serve &
OLLAMA_PID=$!

# 2. Aguarda um momento para o servidor estar pronto
# Usamos 'ollama ps' como um health check nativo para evitar dependências
# externas como curl ou wget, que podem não existir na imagem base.
log_message "Aguardando o serviço Ollama iniciar..."
until ollama ps > /dev/null 2>&1; do
    sleep 2
done
log_message "Servidor Ollama está online!"

# 3. Puxa o modelo de IA padrão (Ollama é idempotente e não baixará se já existir)
log_message "Garantindo que o modelo 'gemma:2b' esteja disponível..."
ollama pull gemma:2b

# 4. Traz o processo do Ollama para o foreground para manter o container ativo
wait $OLLAMA_PID