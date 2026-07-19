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

    request=$(
        jq -n \
            --arg model "$LLM_MODEL" \
            --arg prompt "$prompt" \
            '{
                model:$model,
                prompt:$prompt,
                stream:false
            }'
    )

    local response
    local http_code

    response=$(
        curl \
            -sS \
            --write-out "\nHTTP_STATUS:%{http_code}" \
            --connect-timeout 15 \
            --max-time 300 \
            -H "Content-Type: application/json" \
            -X POST \
            "$OLLAMA_API_URL" \
            -d "$request"
    )

    http_code=$(echo "$response" | sed -n 's/HTTP_STATUS://p')
    response=$(echo "$response" | sed '/HTTP_STATUS:/d')

    if [[ "$http_code" != "200" ]]; then
        log "$RED" "Falha na chamada da API Ollama (HTTP ${http_code})."
        echo "$response"
        exit 1
    fi

    # 2. Verifica se a resposta é HTML (indicativo de erro de proxy/gateway)
    if [[ "$response" == *"</html>"* ]]; then
        log "$RED" "A API retornou uma página HTML em vez de JSON (provável erro de gateway/proxy)."
        log "$RED" "--- Resposta HTML Recebida ---"
        echo "$response"
        log "$RED" "-----------------------------"
        exit 1
    fi

    # Mesmo com HTTP 200, Ollama pode retornar um erro no corpo do JSON
    if echo "$response" | jq -e '.error' >/dev/null; then
        log "$RED" "API Ollama retornou um erro: $(jq -r '.error' <<<"$response")"
        exit 1
    fi

    local answer
    answer=$(jq -r '.response // empty' <<<"$response")

    if [[ -z "$answer" ]]; then
        log "$RED" "API retornou uma resposta vazia no campo '.response'."
        echo "$response"
        exit 1
    fi

    # Limpa potenciais cercas de Markdown (```json ... ```) que o modelo possa retornar.
    # Esta é uma etapa de sanitização para aumentar a robustez do parser.
    # O `printf` é usado para garantir que a variável seja tratada como uma string literal.
    # O `sed` remove as linhas que contêm apenas as cercas de Markdown.
    answer=$(printf "%s" "$answer" | sed '/^```json$/d;/^```$/d')

    # Valida se a resposta da IA é um JSON válido
    if ! jq -e . >/dev/null 2>&1 <<<"$answer"; then
        log "$RED" "A resposta da IA não é um JSON válido."
        log "$RED" "--- Resposta Recebida ---"
        echo "$answer"
        log "$RED" "-------------------------"
        exit 1
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

    local content
    content=$(<"$artifact")
    local file_hash
    file_hash=$(sha256sum "$artifact" | awk '{print $1}')

    # Constrói o prompt final a partir do template e do conteúdo do arquivo
    local prompt_template
    prompt_template=$(<"$PROMPT_TEMPLATE_FILE")
    local prompt
    # Substitui um placeholder no template pelo nome do arquivo
    prompt=$(printf "%s\n\nConteúdo do arquivo '%s':\n\n%s" "$prompt_template" "${artifact##*/}" "$content")

    log "$BLUE" "Solicitando análise da IA..."
    local llm_json_response
    llm_json_response=$(call_llm "$prompt")

    # --- Processamento do Relatório e Quality Gate ---
    local status score summary

    # Valida a estrutura do JSON
    if ! jq -e 'has("status") and has("risk") and has("score") and has("summary") and has("issues")' >/dev/null <<<"$llm_json_response"; then
        log "$RED" "A resposta da IA não contém todos os campos JSON obrigatórios."
        log "$RED" "--- Resposta Recebida ---"
        echo "$llm_json_response"
        log "$RED" "-------------------------"
        exit 1
    fi

    status=$(jq -r '.status' <<<"$llm_json_response")
    score=$(jq -r '.score' <<<"$llm_json_response")
    summary=$(jq -r '.summary' <<<"$llm_json_response")

    # Valida o valor do status
    case "$status" in
        PASS|FAIL)
            ;; # OK
        *)
            log "$RED" "Valor de 'status' inválido na resposta da IA: '$status'"
            exit 1
            ;;
    esac

    # Valida o valor do score
    if ! [[ "$score" =~ ^[0-9]+$ ]]; then
        log "$RED" "Valor de 'score' não é um número inteiro na resposta da IA: '$score'"
        exit 1
    fi
    if (( score < 0 || score > 100 )); then
        log "$RED" "Valor de 'score' fora do intervalo permitido (0-100) na resposta da IA: '$score'"
        exit 1
    fi

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

    # --- Lógica do Quality Gate ---
    log "$BLUE" "Avaliando Quality Gate... Score: ${score}, Limite: ${MIN_SCORE_THRESHOLD}"
    if [[ "$status" == "FAIL" ]] || ((score < MIN_SCORE_THRESHOLD)); then
        log "$RED" "❌ QUALITY GATE: REPROVADO!"
        log "$RED" "Score (${score}) abaixo do limite de ${MIN_SCORE_THRESHOLD} ou status 'FAIL'."
        exit 1
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