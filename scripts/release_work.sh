#!/bin/bash
#
# Script para Automatizar o Ciclo de Release de Trabalho (RUpload)
#
# Objetivo: Orquestrar a atualização de documentação, geração de post para
# LinkedIn e o ciclo completo de versionamento (add, commit, push).
#
set -euo pipefail

# --- Cores ANSI para Logs ---
COLOR_GREEN='\033[0;32m'
COLOR_YELLOW='\033[0;33m'
COLOR_RED='\033[0;31m'
COLOR_RESET='\033[0m'

# --- Função de Log ---
log_message() {
    local level_color="$1"
    echo -e "$(date '+%Y-%m-%d %H:%M:%S') - ${level_color}${2}${COLOR_RESET}" | tee -a "$LOG_PERSIST_FILE"
}

# --- Variáveis ---
LOG_FILE="Log.md"
ROADMAP_FILE="docs/roadmap.md"
ADR_DIR="docs/adr"
POST_FILE="linkedin_post.txt"
REPO_URL="https://github.com/moraesvalterdev2026-byte/DevOpsLab.git"
LOG_PERSIST_FILE="/tmp/axes_release_work.log"

# --- Cabeçalhos de Arquivos ---
LOG_HEADER="📖 Diário de Bordo - AXES Bank\nEste arquivo documenta a evolução técnica, decisões de arquitetura e o histórico de desenvolvimento do projeto AXES Bank."

COMMIT_TITLE="feat(project): Conclui Fase 1 e automatiza ciclo de trabalho"
COMMIT_BODY="Este commit marca a conclusão da FASE 1 (Fundamentos de Engenharia), formaliza o primeiro ADR e introduz o script 'release_work.sh' para automação do fluxo de versionamento.

O que foi feito:
- Roadmap: LAB 02 (Linux Administration) foi marcado como concluído.
- ADR: Criado o ADR 0001 para formalizar a política de não versionar backups.
- .gitignore: Adicionada a pasta 'backups/' para garantir a aplicação do ADR 0001.
- Makefile: Aprimorado com um alvo 'help' e uma nova regra 'release'.
- Automação: Adicionado o script 'release_work.sh' para padronizar o ciclo de trabalho."

# --- Funções ---

check_dependencies() {
    log_message "${COLOR_YELLOW}" "Verificando dependências de ferramentas..."
    local missing_deps=false
    for cmd in git sed mktemp tail tee printf; do
        if ! command -v "$cmd" &> /dev/null; then
            log_message "${COLOR_RED}" "❌ ERRO CRÍTICO: Dependência '${cmd}' não encontrada no PATH."
            missing_deps=true
        else
            log_message "${COLOR_GREEN}" "✅ Dependência '${cmd}' OK."
        fi
    done
    if [ "$missing_deps" = true ]; then
        log_message "${COLOR_RED}" "❌ Processo abortado devido a dependências ausentes."
        exit 1
    fi
}

ensure_files_exist() {
    log_message "${COLOR_YELLOW}" "Verificando a existência de arquivos de documentação..."
    if [[ ! -f "$LOG_FILE" ]]; then
        log_message "${COLOR_YELLOW}" "⚠️  Arquivo '${LOG_FILE}' não encontrado. Criando esqueleto."
        echo -e "$LOG_HEADER" > "$LOG_FILE"
    fi
    if [[ ! -f "$ROADMAP_FILE" ]]; then
        log_message "${COLOR_YELLOW}" "⚠️  Arquivo '${ROADMAP_FILE}' não encontrado. Criando esqueleto."
        echo -e "# 🗺️ Roadmap de Implementação - AXES Bank" > "$ROADMAP_FILE"
    fi
}

update_docs() {
    log_message "${COLOR_YELLOW}" "Atualizando documentação..."
    sed -i'' 's|\[ \] \*\*LAB 02: Linux Administration\*\*|[x] \*\*LAB 02: Linux Administration\*\*|' "$ROADMAP_FILE"
    log_message "${COLOR_GREEN}" "✅ Roadmap atualizado: LAB 02 concluído."
}

update_log_md() {
    log_message "${COLOR_YELLOW}" "Gerando nova entrada para o Diário de Bordo (${LOG_FILE})..."
    LOG_TITLE=$(echo "$COMMIT_TITLE" | sed -e 's/feat(project): //g' -e 's/\b\(.\)/\u\1/g')
    
    local temp_log
    temp_log=$(mktemp)
    
    echo -e "$LOG_HEADER" > "$temp_log"
    printf "\n📅 %s | Registro: %s 💎\n" "$(date "+%Y-%m-%d")" "${LOG_TITLE}" >> "$temp_log"
    printf "🎯 Status Atual\nCiclo de trabalho finalizado e documentado através da automação 'make release'.\n\n%s\n\n" "${COMMIT_BODY}" >> "$temp_log"
    printf "Registro realizado por Automação.\n***************************************************************************************************************************\n" >> "$temp_log"

    tail -n +3 "$LOG_FILE" >> "$temp_log" 2>/dev/null || true
    mv "$temp_log" "$LOG_FILE"
    log_message "${COLOR_GREEN}" "✅ Diário de Bordo atualizado com sucesso."
}

generate_linkedin_post() {
    log_message "${COLOR_YELLOW}" "Gerando post para o LinkedIn em '${POST_FILE}'..."
    cat > "$POST_FILE" << 'EOM'
### AXES Bank DevOps Portfolio Update ###

Concluímos um ciclo de desenvolvimento focado em solidificar as fundações de engenharia e automação do nosso projeto.

**Relato Técnico do Período:**

1.  **Finalização da FASE 1 - Fundamentos de Engenharia:** Todos os laboratórios base foram concluídos.
2.  **Melhoria da Experiência do Desenvolvedor (DX):** Makefile refatorado para maior robustez.
3.  **Estabelecimento de Padrões de Arquitetura:** Criamos nosso primeiro ADR.

**Call to Action (CTA):**
Estou construindo este projeto de forma pública e colaborativa. Feedbacks, sugestões e contribuições são muito bem-vindos.

#DevOps #SRE #PlatformEngineering #Git #Automation #Bash #Portfolio
EOM
    printf "\n**Repositório:** %s\n" "${REPO_URL}" >> "$POST_FILE"
    log_message "${COLOR_GREEN}" "✅ Post gerado com sucesso."
}

perform_git_operations() {
    log_message "${COLOR_YELLOW}" "Iniciando ciclo de versionamento Git..."
    git add .
    git commit -m "$COMMIT_TITLE" -m "$COMMIT_BODY"
    log_message "${COLOR_GREEN}" "✅ Commit realizado."
    
    if [[ -n $(git status --porcelain) ]]; then
        log_message "${COLOR_RED}" "❌ ERRO: Estado do Git impuro. Push abortado."
        exit 1
    fi
    git push
    log_message "${COLOR_GREEN}" "✅ Push concluído com sucesso."
}

# --- Execução Principal ---
check_dependencies
ensure_files_exist
update_docs
update_log_md
generate_linkedin_post
perform_git_operations

log_message "${COLOR_GREEN}" "Processo de 'RUpload' finalizado."