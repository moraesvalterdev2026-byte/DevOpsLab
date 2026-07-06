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
    # Marca o LAB 02 como concluído no Roadmap
    sed -i'' 's|\[ \] \*\*LAB 02: Linux Administration\*\*|[x] **LAB 02: Linux Administration**|' "$ROADMAP_FILE"
    log_message "${COLOR_GREEN}" "✅ Roadmap atualizado: LAB 02 concluído."

    # A criação do ADR e a atualização do Log.md já foram feitas,
    # esta função pode ser expandida para futuras automações.
}

update_log_md() {
    log_message "${COLOR_YELLOW}" "Gerando nova entrada para o Diário de Bordo (${LOG_FILE})..."
    # Extrai o título do commit para usar como título do log
    LOG_TITLE=$(echo "$COMMIT_TITLE" | sed -e 's/feat(project): //g' -e 's/\b\(.\)/\u\1/g')
    
    # Prepara o conteúdo do novo log usando Here-Doc
    NEW_LOG_ENTRY=$(cat <<-EOM
📅 $(date "+%Y-%m-%d") | Registro: ${LOG_TITLE} 💎
🎯 Status Atual
Ciclo de trabalho finalizado e documentado através da automação 'make release'. As seguintes alterações foram consolidadas e versionadas:

${COMMIT_BODY}

Registro realizado por Automação.

***************************************************************************************************************************
EOM
)

    # Usa um método robusto para inserir o novo conteúdo no topo do arquivo,
    # evitando problemas com caracteres especiais no `sed`.
    local temp_log
    temp_log=$(mktemp) || { log_message "${COLOR_RED}" "❌ ERRO: Falha ao criar arquivo temporário."; exit 1; }
    
    # Escreve o cabeçalho, a nova entrada e o conteúdo antigo no arquivo temporário
    echo -e "$LOG_HEADER" > "$temp_log"
    echo -e "\n${NEW_LOG_ENTRY}" >> "$temp_log"
    tail -n +3 "$LOG_FILE" >> "$temp_log" # Adiciona o conteúdo antigo, pulando os cabeçalhos antigos

    # Substitui o arquivo de log original pelo novo
    mv "$temp_log" "$LOG_FILE"
    log_message "${COLOR_GREEN}" "✅ Diário de Bordo atualizado com sucesso."
}

generate_linkedin_post() {
    log_message "${COLOR_YELLOW}" "Gerando post para o LinkedIn em '${POST_FILE}'..."
    cat > "$POST_FILE" <<- EOM
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

**Repositório:** ${REPO_URL}
EOM

    log_message "${COLOR_GREEN}" "✅ Post gerado com sucesso."
}

perform_git_operations() {
    log_message "${COLOR_YELLOW}" "Iniciando ciclo de versionamento Git..."
    git add .
    
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

# --- Execução Principal ---
ensure_files_exist
update_docs
update_log_md
generate_linkedin_post
perform_git_operations

log_message "${COLOR_GREEN}" "Processo de 'RUpload' finalizado."
