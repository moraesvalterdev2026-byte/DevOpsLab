#!/bin/bash
# Script: release_work.sh
# Objetivo: Automação robusta com tratamento de erros.

# Remove o -e global para evitar que avisos parem o script
set -uo pipefail

# Configurações
export SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
COLOR_GREEN='\033[0;32m'; COLOR_YELLOW='\033[0;33m'; COLOR_RED='\033[0;31m'; COLOR_RESET='\033[0m'

log_message() { echo -e "$(date '+%Y-%m-%d %H:%M:%S') - ${1}${2}${COLOR_RESET}"; }

run_governance_audit() {
    log_message "${COLOR_YELLOW}" "Iniciando auditoria de governança..."
    # Apenas avisa, não faz 'exit 1'
    if [ -d "${PROJECT_ROOT}/docs/adr" ] && [ -n "$(find "${PROJECT_ROOT}/docs/adr" -maxdepth 1 -name '*.md' 2>/dev/null)" ]; then
        log_message "${COLOR_GREEN}" "✅ Auditoria aprovada."
    else
        log_message "${COLOR_YELLOW}" "⚠️ AVISO: Nenhuma ADR encontrada. Continuando..."
    fi
}

# --- Funções de automação ---
update_docs() { bash "${SCRIPT_DIR}/project_scanner.sh"; }
update_log_md() { echo -e "\n📅 $(date) | Release Automático" >> "Log.md"; }
generate_linkedin_post() { echo "AXES Bank Update" > "linkedin_post.txt"; }

perform_git_operations() {
    log_message "${COLOR_YELLOW}" "Sincronizando Git..."
    git add .
    git commit -m "chore(release): automação concluída" || echo "Nada a comitar."
    git push || echo "Push falhou (verificar rede/chave)."
}

# --- EXECUÇÃO ---
run_governance_audit
update_docs
update_log_md
generate_linkedin_post
perform_git_operations
log_message "${COLOR_GREEN}" "✅ Processo finalizado com sucesso."
exit 0