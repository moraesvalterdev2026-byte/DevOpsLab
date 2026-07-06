#!/bin/bash
#
# --- Configuração de Robustez ---
set -euo pipefail

# Define caminhos absolutos, ignorando qualquer contexto externo instável
export SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
export PATH="/usr/local/bin:/usr/bin:/bin:$PATH"

# Garante que variáveis críticas existam
: "${PROJECT_ROOT:?Erro: PROJECT_ROOT não foi definido}"

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
LOG_PERSIST_FILE="/tmp/axes_release_work.log" # Arquivo de log persistente

# --- Cabeçalhos de Arquivos ---
LOG_HEADER="📖 Diário de Bordo - AXES Bank\nEste arquivo documenta a evolução técnica, decisões de arquitetura e o histórico de desenvolvimento do projeto AXES Bank."

# Define a mensagem de commit. O uso de múltiplas flags -m cria parágrafos.
COMMIT_TITLE="feat(project): Conclui Fase 1 e automatiza ciclo de trabalho"
COMMIT_BODY="Este commit marca a conclusão da FASE 1 (Fundamentos de Engenharia), formaliza o primeiro ADR e introduz o script 'release_work.sh' para automação do fluxo de versionamento.

O que foi feito:
- Roadmap: LAB 02 (Linux Administration) foi marcado como concluído.
- ADR: Criado o ADR 0001 para formalizar a política de não versionar backups.
- .gitignore: Adicionada a pasta 'backups/' para garantir a aplicação do ADR 0001.
- Makefile: Aprimorado com um alvo 'help' e uma nova regra 'release'.
- Automação: Adicionado o script 'release_work.sh' para padronizar o ciclo de trabalho."

# --- Funções ---

# --- Ajuste Crítico na Verificação de Dependências ---
check_dependencies() {
    log_message "${COLOR_YELLOW}" "Verificando dependências..."
    # Se algum comando essencial faltar, não queremos um erro 'unbound'
    local deps=("git" "sed" "mktemp" "tail" "tee" "printf")
    for cmd in "${deps[@]}"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            echo "ERRO: Comando $cmd não encontrado no PATH: $PATH" >&2
            exit 1
        fi
    done
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
    log_message "${COLOR_YELLOW}" "Sincronizando roadmap com o estado do projeto..."
    bash "${SCRIPT_DIR}/project_scanner.sh"

    # A criação do ADR e a atualização do Log.md já foram feitas,
    # esta função pode ser expandida para futuras automações.
}

update_log_md() {
    log_message "${COLOR_YELLOW}" "Gerando nova entrada para o Diário de Bordo (${LOG_FILE})..."
    # Extrai o título do commit para usar como título do log
    LOG_TITLE=$(echo "$COMMIT_TITLE" | sed -e 's/feat(project): //g' -e 's/\b\(.\)/\u\1/g')
    
    # Usa um método robusto para inserir o novo conteúdo no topo do arquivo,
    # evitando problemas com caracteres especiais no `sed`.
    local temp_log
    temp_log=$(mktemp) || { log_message "${COLOR_RED}" "❌ ERRO: Falha ao criar arquivo temporário."; exit 1; }
    
    # Escreve o cabeçalho, a nova entrada e o conteúdo antigo no arquivo temporário
    echo -e "$LOG_HEADER" > "$temp_log"

    # Constrói a nova entrada de log de forma segura usando printf
    printf "\n📅 %s | Registro: %s 💎\n" "$(date "+%Y-%m-%d")" "${LOG_TITLE}" >> "$temp_log"
    printf "🎯 Status Atual\n" >> "$temp_log"
    printf "Ciclo de trabalho finalizado e documentado através da automação 'make release'. As seguintes alterações foram consolidadas e versionadas:\n\n" >> "$temp_log"
    printf "%s\n\n" "${COMMIT_BODY}" >> "$temp_log"
    printf "Registro realizado por Automação.\n\n" >> "$temp_log"
    printf "***************************************************************************************************************************\n" >> "$temp_log"

    tail -n +3 "$LOG_FILE" >> "$temp_log" # Adiciona o conteúdo antigo, pulando os cabeçalhos antigos

    # Substitui o arquivo de log original pelo novo
    mv "$temp_log" "$LOG_FILE"
    log_message "${COLOR_GREEN}" "✅ Diário de Bordo atualizado com sucesso."
}

generate_linkedin_post() {
    log_message "${COLOR_YELLOW}" "Gerando post para o LinkedIn em '${POST_FILE}'..."
    # Usa 'EOM' com aspas para desativar a expansão de variáveis no bloco estático
    cat > "$POST_FILE" << 'EOM'
### AXES Bank DevOps Portfolio Update ###

Concluímos um ciclo de desenvolvimento focado em solidificar as fundações de engenharia e automação do nosso projeto.

**Relato Técnico do Período:**

1.  **Finalização da FASE 1 - Fundamentos de Engenharia:** Todos os laboratórios base foram concluídos, incluindo a automação de tarefas administrativas com Bash e Cron (`LAB 02`). A plataforma agora possui uma rotina de backup diário do banco de dados PostgreSQL, garantindo a resiliência dos dados.

2.  **Melhoria da Experiência do Desenvolvedor (DX):** O `Makefile` foi refatorado para incluir um alvo `help` autodocumentado e variáveis para caminhos, tornando o ambiente de desenvolvimento local mais robusto e fácil de usar.

3.  **Estabelecimento de Padrões de Arquitetura:** Criamos nosso primeiro Architectural Decision Record (ADR 0001), formalizando a decisão crítica de não versionar backups no Git. Esta prática demonstra um compromisso com a segurança e a eficiência do repositório.

Este trabalho de "lapidação", onde refinamos processos e documentamos decisões, é o que diferencia um projeto robusto. A base agora está mais sólida do que nunca para avançarmos para a automação de CI/CD (FASE 2).

**Call to Action (CTA):**
Estou construindo este projeto de forma pública e colaborativa. Feedbacks, sugestões e contribuições são muito bem-vindos. Acompanhe a evolução e participe!

#DevOps #SRE #PlatformEngineering #Git #Automation #Bash #Portfolio #SoftwareEngineering #BuildInPublic
EOM

    # Adiciona a parte dinâmica de forma segura
    printf "\n**Repositório:** %s\n" "${REPO_URL}" >> "$POST_FILE"
    log_message "${COLOR_GREEN}" "✅ Post gerado com sucesso."
}

perform_git_operations() { # Esta função agora depende de COMMIT_TITLE e COMMIT_BODY estarem definidos
    log_message "${COLOR_YELLOW}" "Iniciando ciclo de versionamento Git..."
    log_message "${COLOR_YELLOW}" "------------------ GIT STATUS ------------------"
    git status
    log_message "${COLOR_YELLOW}" "----------------------------------------------"
    
    log_message "${COLOR_YELLOW}" "Realizando commit..."
    git commit -m "$COMMIT_TITLE" -m "$COMMIT_BODY"
    log_message "${COLOR_GREEN}" "✅ Commit realizado com sucesso."
    
    # Verificação de segurança antes do push
    if [[ -n $(git status --porcelain) ]]; then
        log_message "${COLOR_RED}" "❌ ERRO: O diretório de trabalho não está limpo após o commit. Push abortado."
        exit 1
    fi

    log_message "${COLOR_YELLOW}" "Realizando push para o repositório remoto..."
    git push
    log_message "${COLOR_GREEN}" "✅ Push concluído com sucesso."
}

detect_changes_and_set_commit_msg() {
    log_message "${COLOR_YELLOW}" "Detectando tipo de alterações para a mensagem de commit..."
    # Usamos git diff --cached para ver o que está no staging area
    if git diff --cached --quiet --exit-code -- "${PROJECT_ROOT}/docs/adr/" &>/dev/null; then
        # Nenhuma mudança nos ADRs
        COMMIT_TITLE="chore(project): Sincronização de rotina e atualização de documentos"
        COMMIT_BODY="Manutenção regular do projeto, incluindo atualização de logs e roadmap."
    else
        # Verifica se há novos ADRs no staging area
        if git diff --cached --name-only --diff-filter=A "${PROJECT_ROOT}/docs/adr/" | grep -q ".md"; then
            COMMIT_TITLE="docs(governance): Formaliza nova decisão arquitetural"
            COMMIT_BODY="Este release inclui a formalização de uma ou mais decisões arquiteturais (ADRs), reforçando a governança e a rastreabilidade do projeto."
        # Verifica se há ADRs modificados no staging area
        elif git diff --cached --name-only --diff-filter=M "${PROJECT_ROOT}/docs/adr/" | grep -q ".md"; then
            COMMIT_TITLE="docs(governance): Atualiza decisão arquitetural existente"
            COMMIT_BODY="Este release inclui a atualização de uma ou mais decisões arquiteturais (ADRs), refletindo refinamentos ou novas informações."
        fi
    fi
}

# --- Execução Principal ---
check_dependencies
ensure_files_exist

# 1. Adiciona tudo ao staging primeiro para permitir a inspeção do diff
log_message "${COLOR_YELLOW}" "Adicionando todas as alterações ao staging area..."
git add .
# 2. Agora podemos detectar o que foi mudado de fato
detect_changes_and_set_commit_msg

# 3. Prossegue com a documentação e versionamento
update_docs # Chama o scanner, que agora também será adicionado ao commit
update_log_md
generate_linkedin_post

# 4. Git operations apenas realiza o commit e push (já que o add foi feito)
perform_git_operations

log_message "${COLOR_GREEN}" "✅ Processo de 'RUpload' finalizado com sucesso."
