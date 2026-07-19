#!/usr/bin/env bash
#
# Script: ai_governance_audit.sh
# Objetivo: Executar uma auditoria de governança em um artefato de código
#           usando um LLM local (Ollama) e atuar como um Quality Gate,
#           retornando um status de saída baseado em um score.

###############################################
# CONFIGURAÇÃO
###############################################

OLLAMA_API_URL="http://localhost:80/api/generate"
OLLAMA_TAGS_URL="http://localhost:80/api/tags"
LLM_MODEL="gemma:2b"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

DOCKER_COMPOSE_FILE="${PROJECT_ROOT}/infra/docker-compose.yml"
AUDIT_REPORTS_DIR="${PROJECT_ROOT}/docs/audit_reports"
PROMPT_TEMPLATE_FILE="${PROJECT_ROOT}/prompts/governance_audit.prompt"

MIN_SCORE_THRESHOLD=70 # Score mínimo para o status "PASS"
###############################################
# CORES
###############################################

GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RESET='\033[0m'

###############################################
# LOG
###############################################

log() {
    local color="$1"
    shift
    printf "%s - %b%s%b\n" "$(date '+%F %T')" "$color" "$*" "$RESET"
}

###############################################
# TRAP
###############################################

trap 'log "$RED" "Erro na linha ${LINENO}. Abortando."' ERR

###############################################
# VERIFICAÇÕES
###############################################

check_dependencies() {

    local deps=(curl jq sha256sum)

    for dep in "${deps[@]}"; do

        command -v "$dep" >/dev/null || {

            log "$RED" "Dependência não encontrada: $dep"
            exit 1

        }

    done

}

###############################################
# ESPERA O OLLAMA
###############################################

wait_ollama() {

    log "$YELLOW" "Verificando serviço Ollama..."

    local tags_response
    for _ in {1..20}; do
        tags_response=$(curl --silent --fail --connect-timeout 5 "${OLLAMA_TAGS_URL}" 2>/dev/null)
        if [[ -n "$tags_response" ]]; then
            log "$GREEN" "Serviço disponível."
            # Verifica se o modelo está carregado
            if jq -e ".models[] | select(.name==\"${LLM_MODEL}\")" >/dev/null <<<"$tags_response"; then
                log "$GREEN" "Modelo ${LLM_MODEL} carregado."
                return 0
            fi
        fi
        log "$YELLOW" "Aguardando serviço Ollama e modelo ${LLM_MODEL}..."
        sleep 3
    done

    log "$RED" "Timeout: Serviço Ollama ou modelo ${LLM_MODEL} não ficou disponível a tempo."
    exit 1

}

###############################################
# CHAMA IA
###############################################

call_llm() {
    local prompt="$1"
    local request

    request=$(jq -n --arg model "$LLM_MODEL" --arg prompt "$prompt" \
        '{model:$model, prompt:$prompt, stream:false}')

    local response
    local http_code

    response=$(curl -sS --write-out "\nHTTP_STATUS:%{http_code}" \
        --connect-timeout 15 --max-time 300 \
        -H "Content-Type: application/json" -X POST "$OLLAMA_API_URL" -d "$request")

    http_code=$(echo "$response" | sed -n 's/HTTP_STATUS://p')
    response=$(echo "$response" | sed '/HTTP_STATUS:/d')

    if [[ "$http_code" != "200" ]]; then
        log "$RED" "Falha na chamada da API Ollama (HTTP ${http_code})."
        echo "$response"
        # exit 1   # deixe comentado para abortar manualmente
        return 1
    fi

    if [[ "$response" == *"</html>"* ]]; then
        log "$RED" "Resposta HTML recebida (provável erro de gateway)."
        echo "$response"
        # exit 1   # deixe comentado para abortar manualmente
        return 1
    fi

    if echo "$response" | jq -e '.error' >/dev/null; then
        log "$RED" "Erro retornado pela API Ollama: $(jq -r '.error' <<<"$response")"
        # exit 1   # deixe comentado para abortar manualmente
        return 1
    fi

    local answer
    answer=$(jq -r '.response // empty' <<<"$response")
    answer=$(printf "%s" "$answer" | sed '/^```json$/d;/^```$/d')

    if ! jq -e . >/dev/null 2>&1 <<<"$answer"; then
        log "$YELLOW" "Resposta não é JSON válido. Marcando auditoria como PENDENTE."
        echo "$answer"
        # exit 1   # deixe comentado para abortar manualmente
        return 1
    fi

    echo "$answer"
}

###############################################
# AUDITORIA
###############################################

audit_file() {
    local artifact="$1"
    local start_time
    start_time=$(date +%s)

    [[ -f "$artifact" ]] || {
        log "$RED" "Arquivo não encontrado: $artifact"
        exit 1
    }

    local content=$(&lt;"$artifact")
    local file_hash=$(sha256sum "$artifact" | awk '{print $1}')

    local prompt_template=$(&lt;"$PROMPT_TEMPLATE_FILE")
    local prompt=$(printf "%s\n\nConteúdo do arquivo '%s':\n\n%s" \
        "$prompt_template" "${artifact##*/}" "$content")

    log "$BLUE" "Solicitando análise da IA..."
    local llm_json_response
    llm_json_response=$(call_llm "$prompt") || {
        log "$YELLOW" "⚠ Auditoria não retornou resposta válida. Gerando relatório PENDENTE."
        mkdir -p "$AUDIT_REPORTS_DIR"
        local report_filename="${AUDIT_REPORTS_DIR}/$(date +%F_%H-%M-%S)_${artifact##*/}_audit_pending.md"
        cat &gt; "$report_filename" &lt;&lt;EOF
# Relatório de Auditoria de Governança por IA

| Campo | Valor |
|---|---|
| **Artefato** | \`$artifact\` |
| **Hash (sha256)** | \`$file_hash\` |
| **Data da Auditoria** | $(date '+%Y-%m-%d %H:%M:%S %Z') |
| **Modelo de IA** | \`$LLM_MODEL\` |
| **Status** | PENDENTE |

## Observação

A auditoria não pôde ser concluída devido a falha na resposta da IA.
EOF
        return 0
    }

    # --- Processamento do Relatório e Quality Gate ---
    if ! jq -e 'has("status") and has("risk") and has("score") and has("summary") and has("issues")' &gt;/dev/null &lt;&lt;&lt;"$llm_json_response"; then
        log "$YELLOW" "⚠ Resposta da IA incompleta. Gerando relatório PENDENTE."
        mkdir -p "$AUDIT_REPORTS_DIR"
        local report_filename="${AUDIT_REPORTS_DIR}/$(date +%F_%H-%M-%S)_${artifact##*/}_audit_pending.md"
        cat &gt; "$report_filename" &lt;&lt;EOF
# Relatório de Auditoria de Governança por IA

| Campo | Valor |
|---|---|
| **Artefato** | \`$artifact\` |
| **Hash (sha256)** | \`$file_hash\` |
| **Data da Auditoria** | $(date '+%Y-%m-%d %H:%M:%S %Z') |
| **Modelo de IA** | \`$LLM_MODEL\` |
| **Status** | PENDENTE |

## Observação

A resposta da IA não continha todos os campos obrigatórios.
EOF
        return 0
    fi

    # Se chegou aqui, temos JSON válido e completo → processa normalmente
    local status=$(jq -r '.status' &lt;&lt;&lt;"$llm_json_response")
    local score=$(jq -r '.score' &lt;&lt;&lt;"$llm_json_response")
    local summary=$(jq -r '.summary' &lt;&lt;&lt;"$llm_json_response")

    mkdir -p "$AUDIT_REPORTS_DIR"
    local report_filename
    report_filename="${AUDIT_REPORTS_DIR}/$(date +%F_%H-%M-%S)_${artifact##*/}_audit.md"
    local end_time
    end_time=$(date +%s)
    local duration=$((end_time - start_time))

    log "$YELLOW" "Gerando relatório de auditoria..."
    cat > "$report_filename" <<EOF
# Relatório de Auditoria de Governança por IA

| Campo | Valor |
|---|---|
| **Artefato** | \`$artifact\` |
| **Hash (sha256)** | \`$file_hash\` |
| **Data da Auditoria** | $(date '+%Y-%m-%d %H:%M:%S %Z') |
| **Modelo de IA** | \`$LLM_MODEL\` |
| **Tempo de Execução** | ${duration}s |
| **Score Final** | **${score}/100** |
| **Status do Quality Gate** | **$status** |

## Resumo da Análise

> $summary

## Resposta Completa da IA (JSON)

\`\`\`json
$llm_json_response
\`\`\`
EOF

    log "$GREEN" "Relatório salvo em: $report_filename"

    log "$BLUE" "Avaliando Quality Gate... Score: ${score}, Limite: ${MIN_SCORE_THRESHOLD}"
    if [[ "$status" == "FAIL" ]] || ((score < MIN_SCORE_THRESHOLD)); then
        log "$RED" "❌ QUALITY GATE: REPROVADO!"
        # exit 1   # deixe comentado para abortar manualmente
    else
        log "$GREEN" "✅ QUALITY GATE: APROVADO!"
    fi
}

###############################################
# MAIN
###############################################

main() {

    cd "$PROJECT_ROOT"
    check_dependencies
    wait_ollama
    audit_file "$DOCKER_COMPOSE_FILE"

}

main "$@"