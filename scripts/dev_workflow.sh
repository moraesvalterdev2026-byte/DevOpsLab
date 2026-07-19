#!/bin/bash
#
# Script: dev_workflow.sh
# Objetivo: Orquestrar uma sequência de comandos comuns para o fluxo de trabalho
#           do desenvolvedor no projeto AXES Bank.
#

# --- Configuração de Robustez ---
set -euo pipefail

# --- Cores e Funções de Log ---
COLOR_GREEN='\033[0;32m'
COLOR_YELLOW='\033[0;33m'
COLOR_BLUE='\033[0;34m'
COLOR_RESET='\033[0m'

log_message() {
    local level_color="$1"
    echo -e "\n$(date '+%Y-%m-%d %H:%M:%S') - ${level_color}--- ${2} ---${COLOR_RESET}"
}

# Carrega variáveis de ambiente de um arquivo .env na raiz do projeto, se existir.
load_env_file() {
    local env_file
    env_file="$(dirname "${BASH_SOURCE[0]}")/../.env"
    if [ -f "$env_file" ]; then
        log_message "${COLOR_YELLOW}" "Carregando variáveis de ambiente do arquivo .env"
        # 'set -a' exporta todas as variáveis definidas a partir deste ponto.
        set -a; source "$env_file"; set +a
    fi
}

# --- Funções do Workflow ---

# Garante que o ambiente de desenvolvimento esteja rodando.
ensure_env_is_up() {
    log_message "${COLOR_BLUE}" "Verificando status do ambiente Docker"
    # Verifica se o container 'axes_app' está rodando.
    if ! docker ps --filter "name=axes_app" --filter "status=running" | grep -q "axes_app"; then
        log_message "${COLOR_YELLOW}" "Ambiente não está no ar. Executando 'make up'..."
        make up
        log_message "${COLOR_GREEN}" "Ambiente iniciado com sucesso."
    else
        log_message "${COLOR_GREEN}" "Ambiente já está no ar."
        make status
    fi
}

# Executa o scanner do projeto para verificar o progresso.
run_project_scan() {
    log_message "${COLOR_BLUE}" "Executando o scanner de projeto"
    make scan
}

# Executa o linter para garantir a qualidade do código.
run_lint() {
    log_message "${COLOR_BLUE}" "Executando o Linter para análise estática do código"
    npm run lint
}

# Executa a suíte de testes.
run_tests() {
    log_message "${COLOR_BLUE}" "Executando a suíte de testes (Jest)"
    npm run test
}

# Executa a auditoria de governança com IA.
run_ai_audit() {
    log_message "${COLOR_BLUE}" "Executando a auditoria de governança com IA"
    make audit-ai
}

# --- Execução Principal ---
log_message "${COLOR_GREEN}" "INICIANDO WORKFLOW DE DESENVOLVIMENTO DO AXES BANK"
load_env_file
ensure_env_is_up
run_project_scan
run_lint
run_tests
run_ai_audit
log_message "${COLOR_GREEN}" "WORKFLOW DE DESENVOLVIMENTO CONCLUÍDO"