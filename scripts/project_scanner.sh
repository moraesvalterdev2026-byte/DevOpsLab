#!/bin/bash
#
# Script de Análise e Planejamento (Project Scanner)
#
# Objetivo: Escanear o estado atual do projeto, comparar com o roadmap,
# atualizar o status dos laboratórios e sugerir o próximo passo estratégico.
#
set -euo pipefail

# --- Cores ANSI para Logs ---
COLOR_GREEN='\033[0;32m'
COLOR_YELLOW='\033[0;33m'
COLOR_RED='\033[0;31m'
COLOR_RESET='\033[0m'

# --- Função de Log ---
# Imprime mensagens com timestamp e nível de cor.
# Uso: log_message "NÍVEL" "Sua mensagem"
log_message() {
    local level_color="$1"
    echo -e "$(date '+%Y-%m-%d %H:%M:%S') - ${level_color}${2}${COLOR_RESET}" | tee -a "$LOG_PERSIST_FILE"
}

# --- Variáveis ---
# Descobre o diretório raiz do projeto, subindo um nível a partir do diretório do script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
ROADMAP_FILE="${PROJECT_ROOT}/docs/roadmap.md"
LOG_PERSIST_FILE="/tmp/axes_project_scan.log"
DRY_RUN=false

# --- Processamento de Argumentos ---
if [[ "${1:-}" == "--dry-run" ]]; then
    DRY_RUN=true
fi

# --- Funções ---

check_git_branch() {
    # Garante que estamos em um repositório git antes de prosseguir
    if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
        log_message "${COLOR_YELLOW}" "⚠️ AVISO: Não está em um repositório Git. Verificação de branch pulada."
        return
    fi

    local current_branch
    current_branch=$(git rev-parse --abbrev-ref HEAD)
    if [[ "$current_branch" != "main" ]]; then
        log_message "${COLOR_YELLOW}" "⚠️ AVISO: Executando fora da branch 'main' (branch atual: '${current_branch}')."
    fi
}

update_roadmap_status() {
    log_message "${COLOR_YELLOW}" "🔎 Escaneando o projeto para atualizar o roadmap..."
    if [ "$DRY_RUN" = true ]; then
        log_message "${COLOR_YELLOW}" "💧 MODO DRY-RUN ATIVADO: Nenhuma alteração será salva."
    fi

    # 1. Verificações de Robustez
    if [[ ! -f "$ROADMAP_FILE" ]]; then
        log_message "${COLOR_RED}" "❌ ERRO: Arquivo do roadmap não encontrado em '${ROADMAP_FILE}'."
        exit 1
    fi

    local temp_file
    temp_file=$(mktemp) || { log_message "${COLOR_RED}" "❌ ERRO: Falha ao criar arquivo temporário."; exit 1; }

    # Copia o roadmap para o arquivo temporário para aplicar as alterações de forma cumulativa.
    cp "$ROADMAP_FILE" "$temp_file"

    # 2. Detecção de Compatibilidade do `sed` (GNU vs BSD/macOS)
    local sed_inplace_flag='-i'
    if [[ $(uname) == "Darwin" ]]; then
        sed_inplace_flag="-i ''"
    fi

    # 3. Estrutura de Dados Escalável para Verificação dos Laboratórios
    # Formato: "Nome do Lab;Arquivo de Verificação;Tamanho Mínimo (bytes);String de Busca"
    declare -a LABS_TO_CHECK=(
        "LAB 02: Linux Administration;${PROJECT_ROOT}/scripts/backup_database.sh;100;\[ \] \*\*LAB 02: Linux Administration\*\*"
        "LAB 07: Continuous Integration;${PROJECT_ROOT}/.github/workflows/ci.yml;100;\[ \] \*\*LAB 07: Continuous Integration\*\*"
        "LAB 08: Infrastructure as Code;${PROJECT_ROOT}/infra/terraform/main.tf;100;\[ \] \*\*LAB 08: Infrastructure as Code\*\*"
    )

    # 4. Itera sobre a lista de laboratórios e atualiza o arquivo temporário
    for lab_info in "${LABS_TO_CHECK[@]}"; do
        IFS=';' read -r lab_name check_file min_size search_string <<< "$lab_info"

        # Verifica se o arquivo de conclusão do lab existe
        if [[ -f "$check_file" ]]; then
            local file_size
            file_size=$(stat -c%s "$check_file")

            if (( file_size < min_size )); then
                log_message "${COLOR_YELLOW}" "⚠️  ${lab_name} - Artefato '${check_file##*/}' encontrado, mas está abaixo do tamanho mínimo (${file_size} < ${min_size} bytes)."
            else
                # Usa a flag `sed` compatível com o SO e o delimitador '|'
                eval "sed ${sed_inplace_flag} 's|${search_string}|[x] \*\*${lab_name}\*\*|' \"\$temp_file\""
                log_message "${COLOR_GREEN}" "✅ ${lab_name} - Concluído (artefato '${check_file##*/}' encontrado e validado)."
            fi
        fi
    done

    # 5. Move o arquivo temporário modificado de volta para o local original.
    if [ "$DRY_RUN" = false ]; then
        mv "$temp_file" "$ROADMAP_FILE"
        log_message "${COLOR_YELLOW}" "Roadmap atualizado com sucesso."
    else
        rm "$temp_file"
        log_message "${COLOR_YELLOW}" "Simulação concluída. O roadmap não foi modificado."
    fi
}

suggest_next_step() {
    echo # Adiciona uma linha em branco para espaçamento
    log_message "${COLOR_YELLOW}" "🎯 Análise do Próximo Passo Estratégico"
    echo -e "--------------------------------------------------------------------------"

    # Encontra a primeira linha no roadmap que contém um item não concluído '[ ]'
    # e extrai o nome do Laboratório.
    local NEXT_LAB
    NEXT_LAB=$(grep -m 1 '\[ \]' "$ROADMAP_FILE" | sed -n 's|.*\*\(LAB [0-9]\{2\}: [A-Za-z /]*\)\*\*.*|\1|p')

    if [ -n "$NEXT_LAB" ]; then
        echo -e "O próximo passo lógico no seu roadmap é:\n"
        echo -e "➡️  **${NEXT_LAB}**\n"
        echo -e "Este passo está alinhado com a 'Arquitetura Evolutiva' do seu blueprint, movendo o projeto para a próxima fase de maturidade."
    else
        log_message "${COLOR_GREEN}" "🎉 Parabéns! Todos os laboratórios do roadmap foram concluídos!"
    fi
    echo -e "--------------------------------------------------------------------------"
}

# --- Execução Principal ---

check_git_branch
update_roadmap_status
suggest_next_step

log_message "${COLOR_GREEN}" "Análise do projeto finalizada."