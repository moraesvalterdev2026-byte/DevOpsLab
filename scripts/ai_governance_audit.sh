#!/bin/bash
#
# Script: ai_governance_audit.sh
# Objetivo: Utiliza um LLM local (Ollama) para auditar artefatos de governança.
#

# --- Configuração de Robustez ---
set -euo pipefail

# --- Cores e Funções de Log ---
COLOR_GREEN='\033[0;32m'
COLOR_YELLOW='\033[0;33m'
COLOR_RED='\033[0;31m'
COLOR_BLUE='\033[0;34m'
COLOR_RESET='\033[0m'

log_message() {
    local level_color="$1"
    echo -e "$(date '+%Y-%m-%d %H:%M:%S') - ${level_color}${2}${COLOR_RESET}"
}

# --- Variáveis ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
DOCKER_COMPOSE_FILE="${PROJECT_ROOT}/infra/docker-compose.yml"
AUDIT_REPORTS_DIR="${PROJECT_ROOT}/docs/audit_reports"
OLLAMA_API_URL="http://localhost:11434/api/generate"
LLM_MODEL="gemma:2b" # Modelo leve, ideal para tarefas focadas

# --- Funções ---

# Verifica a integridade e as boas práticas de um arquivo docker-compose.yml
# usando um Large Language Model (LLM) local via Ollama.
function verify_docker_compose_integrity() {
    # --- Verificação de Prontidão do Serviço de IA ---
    log_message "${COLOR_YELLOW}" "Verificando a disponibilidade do serviço de IA em ${OLLAMA_API_URL}..."
    local retries=10
    local count=0
    local wait_time=3

    # Use native Bash TCP connection check to avoid dependency on curl/wget.
    # This attempts to open a connection to the host and port.
    until (</dev/tcp/localhost/11434) &>/dev/null; do
        if [ $count -ge $retries ]; then
            log_message "${COLOR_RED}" "❌ ERRO: O serviço de IA não respondeu após ${retries} tentativas."
            exit 1
        fi
        log_message "${COLOR_YELLOW}" "Serviço de IA indisponível. Tentando novamente em ${wait_time} segundos..."
        sleep ${wait_time}
        count=$((count + 1))
    done
    log_message "${COLOR_GREEN}" "✅ Serviço de IA está online."

    log_message "${COLOR_YELLOW}" "🤖 Iniciando auditoria de IA para o arquivo '${DOCKER_COMPOSE_FILE##*/}'..."

    if [[ ! -f "$DOCKER_COMPOSE_FILE" ]]; then
        log_message "${COLOR_RED}" "❌ ERRO: Arquivo docker-compose não encontrado em '${DOCKER_COMPOSE_FILE}'."
        exit 1
    fi

    # 1. Lê o conteúdo do arquivo e escapa para JSON
    local file_content
    file_content=$(jq -Rs . < "$DOCKER_COMPOSE_FILE")

    # 2. Constrói o prompt para o LLM
    local prompt
    local prompt_template

    # We quote 'EOM' to prevent the shell from expanding variables like ${DB_USER:-admin}
    # inside the here-document, which would corrupt the docker-compose content.
    prompt_template=$(cat <<'EOM'
**Contexto da Persona:**
Você atua como um Engenheiro DevOps Sênior, especialista em Governança de Infraestrutura, Segurança e arquitetura de sistemas distribuídos. Sua missão é realizar uma auditoria técnica rigorosa sobre arquivos de infraestrutura como código (IaC).

**Instruções de Análise:**
Analise o conteúdo do arquivo \`docker-compose.yml\` fornecido abaixo. Sua auditoria deve ser técnica, direta e baseada nas melhores práticas de mercado. Foque estritamente nos seguintes pilares:

1. **Segurança e Privilégios:** Identifique riscos como execução como \`root\`, exposição de portas sensíveis, falta de secrets ou uso de imagens com tags instáveis (ex: \`latest\`).
2. **Confiabilidade e Resiliência:** Avalie as políticas de \`restart\`, estratégias de persistência de dados (volumes) e saúde dos serviços (\`healthcheck\`).
3. **Governança e Manutenibilidade:** Avalie a estrutura de redes, labels para organização, versionamento e organização dos serviços.
4. **Otimização:** Sugira melhorias em limites de recursos (\`resources limits\`), dependências entre serviços (\`depends_on\`) e exposição de rede.

**Formato de Saída:**
* Utilize bullet points para cada item identificado.
* Para cada risco encontrado, forneça uma sugestão de correção clara e acionável.
* Mantenha um tom profissional, técnico e conciso (em português).
* Se o arquivo estiver em conformidade com as melhores práticas, destaque os pontos fortes.

**DOCKER-COMPOSE.YML A SER AUDITADO:**
%s
EOM
)
    # Use command substitution with printf to build the final prompt.
    prompt=$(printf "$prompt_template" "$file_content")

    # 3. Constrói o corpo da requisição para a API do Ollama
    local request_body
    request_body=$(jq -n --arg model "$LLM_MODEL" --arg prompt "$prompt" \
    '{
        "model": $model,
        "prompt": $prompt,
        "stream": false
    }')

    # 4. Envia a requisição para o LLM e processa a resposta
    log_message "${COLOR_YELLOW}" "Enviando para análise do modelo '${LLM_MODEL}'. Isso pode levar um momento..."
    
    local response
    response=$(curl -s -X POST "${OLLAMA_API_URL}" -d "$request_body")

    # Robustness: Check if the API returned an error.
    if echo "$response" | jq -e '.error' > /dev/null; then
        local error_message
        error_message=$(echo "$response" | jq -r '.error')
        log_message "${COLOR_RED}" "❌ ERRO: A API do Ollama retornou um erro: ${error_message}"
        log_message "${COLOR_YELLOW}" "Isso geralmente significa que o modelo '${LLM_MODEL}' não foi baixado corretamente. Verifique os logs do container 'axes_ai_agent' com 'docker logs axes_ai_agent'."
        exit 1
    fi

    local llm_answer
    # Extrai a resposta. O uso de `jq -r` remove as aspas e decodifica
    # caracteres de escape como \n, preservando a formatação do LLM.
    # Isso é mais robusto do que concatenar tudo com `tr`.
    llm_answer=$(echo "$response" | jq --raw-output '.response')

    log_message "${COLOR_BLUE}" "--- Resposta do Agente de IA ---"
    echo -e "${llm_answer}"
    log_message "${COLOR_BLUE}" "---------------------------------"

    # 5. Persiste o relatório de auditoria em um arquivo versionado.
    log_message "${COLOR_YELLOW}" "Salvando relatório de auditoria..."
    mkdir -p "${AUDIT_REPORTS_DIR}"
    local report_file="${AUDIT_REPORTS_DIR}/$(date "+%Y-%m-%d")_docker-compose_audit.md"
    echo "# Relatório de Auditoria de IA - $(date "+%Y-%m-%d")" > "${report_file}"
    echo "## Artefato: \`${DOCKER_COMPOSE_FILE##*/}\`" >> "${report_file}"
    echo -e "\n---\n\n${llm_answer}" >> "${report_file}"
    log_message "${COLOR_GREEN}" "✅ Relatório salvo em: ${report_file}"
    log_message "${COLOR_GREEN}" "✅ Auditoria de IA concluída."
}

# --- Execução Principal ---
verify_docker_compose_integrity