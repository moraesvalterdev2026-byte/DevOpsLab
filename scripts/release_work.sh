#!/usr/bin/env bash
# Script: release_work.sh
# Objetivo: Automação inteligente do ciclo de release com governança.

# Configuração de Robustez
set -Eeuo pipefail

# Configurações
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
export PROJECT_ROOT

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
RESET='\033[0m'

# --- Variáveis Globais ---
# Estas serão definidas dinamicamente pela função de detecção.
COMMIT_TITLE=""
COMMIT_BODY=""
START_TIME=$(date +%s)

log() {
    local color="$1"
    shift
    printf "%s - %b%s%b\n" "$(date '+%F %T')" "$color" "$*" "$RESET"
}

trap 'log "$RED" "Erro na linha ${LINENO}. Abortando release."; exit 1' ERR

check_dependencies() {
    local commands=(git bash curl jq docker)
    for cmd in "${commands[@]}"; do
        command -v "$cmd" >/dev/null || {
            log "$RED" "Dependência ausente: $cmd"
            exit 1
        }
    done

    docker compose version >/dev/null 2>&1 || {
        log "$RED" "Docker Compose não encontrado ou não funcional."
        exit 1
    }

    if command -v "shellcheck" >/dev/null; then
        log "$GREEN" "Opcional 'shellcheck' encontrado. Recomenda-se a verificação dos scripts."
    fi
}

run_step() {
    local title="$1"
    shift
    local start
    start=$(date +%s)
    log "$BLUE" "▶ $title"
    "$@"
    local end
    end=$(date +%s)
    log "$GREEN" "✔ $title ($((end - start))s)"
}

run_governance_audit() {
    # A responsabilidade de falhar (exit 1) e logar o erro é totalmente
    # do script 'ai_governance_audit.sh'. Este script apenas o orquestra.
    # O 'set -e' e o 'trap' garantirão que o pipeline pare se a auditoria falhar.
    bash "${SCRIPT_DIR}/ai_governance_audit.sh"
}

run_app_tests() {
    # Executa a suíte de testes da aplicação. Se falhar, o 'set -e' interromperá o pipeline.
    npm run test
}

update_docs() {
    bash "${SCRIPT_DIR}/project_scanner.sh"
}

update_log() {
    log "$YELLOW" "Gerando nova entrada para o Diário de Bordo..."
    local temp_log; temp_log=$(mktemp)
    local log_title; log_title=$(echo "$COMMIT_TITLE" | sed -e 's/feat(frontend): //g' -e 's/docs(governance): //g' -e 's/chore(project): //g' -e 's/\b\(.\)/\u\1/g')

    # Constrói a nova entrada de log de forma segura
    printf "📖 Diário de Bordo - AXES Bank\n" > "$temp_log"
    printf "Este arquivo documenta a evolução técnica, decisões de arquitetura e o histórico de desenvolvimento do projeto AXES Bank.\n\n" >> "$temp_log"
    printf "📅 %s | Registro: %s 💎\n" "$(date "+%F")" "${log_title}" >> "$temp_log"
    printf "🎯 Status Atual\n%s\n\n" "${COMMIT_BODY}" >> "$temp_log"
    printf "Registro realizado por Automação.\n\n***************************************************************************************************************************\n" >> "$temp_log"

    # Adiciona o conteúdo antigo e substitui o arquivo original
    # Garante que o arquivo de log exista antes de tentar ler
    touch "${PROJECT_ROOT}/Log.md"
    tail -n +3 "${PROJECT_ROOT}/Log.md" >> "$temp_log" 2> /dev/null || true
    mv "$temp_log" "${PROJECT_ROOT}/Log.md"
}

generate_linkedin_post() {
    cat > "${PROJECT_ROOT}/linkedin_post.txt" << 'EOM'
### AXES Bank DevOps Portfolio Update ###

Ciclo de desenvolvimento concluído com foco em robustez e governança.

**Relato Técnico:**
Nossas automações (`make scan`, `make release`) foram refatoradas para incluir validação de dependências, logs profissionais com cores e timestamps, e um portão de auditoria que valida a documentação de decisões arquiteturais (ADRs) antes de cada release.

Isso transforma nossos scripts em ferramentas de engenharia de plataforma, garantindo que a qualidade e a disciplina sejam mantidas automaticamente.

#DevOps #PlatformEngineering #Automation #GovernanceAsCode #BuildInPublic
EOM
}

stage_changes() {
    git add .
}

detect_commit_message() {
    log "$YELLOW" "Detectando tipo de alterações para a mensagem de commit..."
    # Usamos git diff --cached para ver o que está no staging area
    if ! git diff --cached --quiet --exit-code -- "${PROJECT_ROOT}/docs/adr/" 2> /dev/null; then
        # Mudanças detectadas nos ADRs
        COMMIT_TITLE="docs(governance): Formaliza ou atualiza decisão arquitetural"
        COMMIT_BODY="Este release inclui a formalização ou atualização de uma ou mais decisões arquiteturais (ADRs), reforçando a governança do projeto."
    elif ! git diff --cached --quiet --exit-code -- "${PROJECT_ROOT}/public/" 2> /dev/null; then
        # Mudanças detectadas no Frontend
        COMMIT_TITLE="feat(frontend): Evolui o ecossistema da aplicação"
        COMMIT_BODY="Implementação de novas funcionalidades ou componentes na interface do usuário, conforme o roadmap do frontend."
    else
        # Nenhuma mudança específica detectada, assume manutenção
        COMMIT_TITLE="chore(project): Sincronização de rotina e atualização de documentos"
        COMMIT_BODY="Manutenção regular do projeto, incluindo atualização de logs e roadmap."
    fi
    log "$GREEN" "Mensagem de commit definida para: '${COMMIT_TITLE}'"
}

git_commit() {
    # Adiciona novamente para incluir os arquivos de log e docs gerados
    git add .

    # Verifica se há de fato algo para comitar de forma segura
    if git diff --cached --quiet; then
        log "$YELLOW" "Nenhuma alteração para commit."
        return
    fi

    git commit -m "$COMMIT_TITLE" -m "$COMMIT_BODY"
}

git_push() {
    # Garante que estamos enviando para a branch correta no 'origin'
    # e protege contra o estado de 'detached HEAD'.
    local current_branch
    current_branch=$(git symbolic-ref --short HEAD 2>/dev/null) || {
        log "$RED" "ERRO: HEAD em modo 'detached'. Abortando push."
        exit 1
    }
    git push origin "$current_branch"
}

main() {
    cd "$PROJECT_ROOT"
    check_dependencies
    run_step "Executar Testes da Aplicação" run_app_tests
    run_step "Governança por IA" run_governance_audit
    run_step "Adicionar arquivos ao Stage" stage_changes
    detect_commit_message
    run_step "Atualizar Documentação (Roadmap)" update_docs
    run_step "Atualizar Diário de Bordo (Log.md)" update_log
    run_step "Gerar Post para LinkedIn" generate_linkedin_post
    run_step "Realizar Commit" git_commit
    run_step "Realizar Push" git_push

    local END_TIME
    END_TIME=$(date +%s)
    local TOTAL_TIME=$((END_TIME - START_TIME))

    log "$GREEN" "Release finalizado com sucesso."
    log "$GREEN" "Tempo total de execução: ${TOTAL_TIME}s"
}

main "$@"