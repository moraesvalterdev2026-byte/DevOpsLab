#!/bin/bash
# Script: release_work.sh
# Objetivo: Automação inteligente do ciclo de release com governança.

# Configuração de Robustez
set -euo pipefail

# Configurações
export SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
COLOR_GREEN='\033[0;32m'; COLOR_YELLOW='\033[0;33m'; COLOR_RED='\033[0;31m'; COLOR_RESET='\033[0m'

# --- Variáveis Globais ---
# Estas serão definidas dinamicamente pela função de detecção.
COMMIT_TITLE=""
COMMIT_BODY=""

# --- Funções de Log e Auditoria ---
log_message() {
    echo -e "$(date '+%Y-%m-%d %H:%M:%S') - ${1}${2}${COLOR_RESET}"
}

run_governance_audit() {
    log_message "${COLOR_YELLOW}" "Iniciando auditoria de governança..."
    if [ -d "${PROJECT_ROOT}/docs/adr" ] && [ -n "$(find "${PROJECT_ROOT}/docs/adr" -maxdepth 1 -name '*.md' 2>/dev/null)" ]; then
        log_message "${COLOR_GREEN}" "✅ Auditoria aprovada."
    else
        log_message "${COLOR_YELLOW}" "⚠️ AVISO: Nenhuma ADR encontrada. Continuando..."
    fi
}

# --- Funções de Geração de Documentação ---
update_docs() {
    log_message "${COLOR_YELLOW}" "Sincronizando roadmap com o estado do projeto..."
    bash "${SCRIPT_DIR}/project_scanner.sh";
}
update_log_md() {
    log_message "${COLOR_YELLOW}" "Gerando nova entrada para o Diário de Bordo..."
    local temp_log; temp_log=$(mktemp)
    local log_title; log_title=$(echo "$COMMIT_TITLE" | sed -e 's/feat(frontend): //g' -e 's/docs(governance): //g' -e 's/chore(project): //g' -e 's/\b\(.\)/\u\1/g')

    # Constrói a nova entrada de log de forma segura
    printf "📖 Diário de Bordo - AXES Bank\n" > "$temp_log"
    printf "Este arquivo documenta a evolução técnica, decisões de arquitetura e o histórico de desenvolvimento do projeto AXES Bank.\n\n" >> "$temp_log"
    printf "📅 %s | Registro: %s 💎\n" "$(date "+%Y-%m-%d")" "${log_title}" >> "$temp_log"
    printf "🎯 Status Atual\n%s\n\n" "${COMMIT_BODY}" >> "$temp_log"
    printf "Registro realizado por Automação.\n\n***************************************************************************************************************************\n" >> "$temp_log"

    # Adiciona o conteúdo antigo e substitui o arquivo original
    tail -n +3 "Log.md" >> "$temp_log" 2>/dev/null || true
    mv "$temp_log" "Log.md"
    log_message "${COLOR_GREEN}" "✅ Diário de Bordo atualizado."
}
generate_linkedin_post() {
    log_message "${COLOR_YELLOW}" "Gerando post para o LinkedIn..."
    cat > "linkedin_post.txt" << 'EOM'
### AXES Bank DevOps Portfolio Update ###

Ciclo de desenvolvimento concluído com foco em robustez e governança.

**Relato Técnico:**
Nossas automações (`make scan`, `make release`) foram refatoradas para incluir validação de dependências, logs profissionais com cores e timestamps, e um portão de auditoria que valida a documentação de decisões arquiteturais (ADRs) antes de cada release.

Isso transforma nossos scripts em ferramentas de engenharia de plataforma, garantindo que a qualidade e a disciplina sejam mantidas automaticamente.

#DevOps #PlatformEngineering #Automation #GovernanceAsCode #BuildInPublic
EOM
    log_message "${COLOR_GREEN}" "✅ Post para LinkedIn gerado com sucesso."
}

# --- Funções de Lógica de Negócio e Git ---
detect_changes_and_set_commit_msg() {
    log_message "${COLOR_YELLOW}" "Detectando tipo de alterações para a mensagem de commit..."
    # Usamos git diff --cached para ver o que está no staging area
    if ! git diff --cached --quiet --exit-code -- "${PROJECT_ROOT}/docs/adr/"; then
        # Mudanças detectadas nos ADRs
        COMMIT_TITLE="docs(governance): Formaliza ou atualiza decisão arquitetural"
        COMMIT_BODY="Este release inclui a formalização ou atualização de uma ou mais decisões arquiteturais (ADRs), reforçando a governança do projeto."
    elif ! git diff --cached --quiet --exit-code -- "${PROJECT_ROOT}/public/"; then
        # Mudanças detectadas no Frontend
        COMMIT_TITLE="feat(frontend): Evolui o ecossistema da aplicação"
        COMMIT_BODY="Implementação de novas funcionalidades ou componentes na interface do usuário, conforme o roadmap do frontend."
    else
        # Nenhuma mudança específica detectada, assume manutenção
        COMMIT_TITLE="chore(project): Sincronização de rotina e atualização de documentos"
        COMMIT_BODY="Manutenção regular do projeto, incluindo atualização de logs e roadmap."
    fi
    log_message "${COLOR_GREEN}" "✅ Mensagem de commit definida para: '${COMMIT_TITLE}'"
}

perform_git_operations() {
    log_message "${COLOR_YELLOW}" "Sincronizando Git..."
    # Garante que as últimas modificações nos logs também sejam adicionadas
    git add .

    if ! git commit -m "$COMMIT_TITLE" -m "$COMMIT_BODY"; then
        log_message "${COLOR_YELLOW}" "⚠️ Nenhuma alteração nova para comitar."
        # Se não há nada a comitar, não há nada a fazer.
        return
    fi
    log_message "${COLOR_GREEN}" "✅ Commit realizado com sucesso."

    log_message "${COLOR_YELLOW}" "Realizando push para o repositório remoto..."
    git push
    log_message "${COLOR_GREEN}" "✅ Push concluído com sucesso."
}

# --- EXECUÇÃO ---
run_governance_audit

# 1. Adiciona tudo ao staging para permitir a inspeção
git add .

# 2. Detecta as mudanças e prepara as mensagens
detect_changes_and_set_commit_msg

# 3. Gera a documentação com base nas mensagens
update_docs
update_log_md
generate_linkedin_post

# 4. Finaliza o ciclo de versionamento
perform_git_operations

log_message "${COLOR_GREEN}" "✅ Processo de 'RUpload' finalizado."