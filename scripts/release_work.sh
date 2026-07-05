#!/bin/bash
#
# Script para Automatizar o Ciclo de Release de Trabalho (RUpload)
#
# Objetivo: Orquestrar a atualização de documentação, geração de post para
# LinkedIn e o ciclo completo de versionamento (add, commit, push).
#
set -euo pipefail

# --- Variáveis ---
LOG_FILE="Log.md"
ROADMAP_FILE="docs/roadmap.md"
ADR_DIR="docs/adr"
POST_FILE="linkedin_post.txt"
REPO_URL="https://github.com/moraesvalterdev2026-byte/DevOpsLab.git"

# --- Funções ---

update_docs() {
    echo ">>> Atualizando documentação..."
    
    # Marca o LAB 02 como concluído no Roadmap
    sed -i 's/\[ \] \*\*LAB 02: Linux Administration\*\*/\[x] \*\*LAB 02: Linux Administration\*\*/' "$ROADMAP_FILE"
    echo "Roadmap atualizado: LAB 02 concluído."

    # A criação do ADR e a atualização do Log.md já foram feitas,
    # esta função pode ser expandida para futuras automações.
}

generate_linkedin_post() {
    echo ">>> Gerando post para o LinkedIn em '${POST_FILE}'..."

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

    echo "Post gerado com sucesso."
}

perform_git_operations() {
    echo ">>> Iniciando ciclo de versionamento Git..."
    
    git add .
    echo "------------------ GIT STATUS ------------------"
    git status
    echo "----------------------------------------------"

    # Define a mensagem de commit. O uso de múltiplas flags -m cria parágrafos.
    COMMIT_TITLE="feat(project): Conclui Fase 1 e automatiza ciclo de trabalho"
    COMMIT_BODY="Este commit marca a conclusão da FASE 1 (Fundamentos de Engenharia), formaliza o primeiro ADR e introduz o script 'release_work.sh' para automação do fluxo de versionamento.

O que foi feito:
- Roadmap: LAB 02 (Linux Administration) foi marcado como concluído.
- ADR: Criado o ADR 0001 para formalizar a política de não versionar backups.
- .gitignore: Adicionada a pasta 'backups/' para garantir a aplicação do ADR 0001.
- Makefile: Aprimorado com um alvo 'help' e uma nova regra 'release'.
- Automação: Adicionado o script 'release_work.sh' para padronizar o ciclo de trabalho."

    echo ">>> Realizando commit..."
    git commit -m "$COMMIT_TITLE" -m "$COMMIT_BODY"
    echo "Commit realizado com sucesso."

    echo ">>> Realizando push para o repositório remoto..."
    git push
    echo "Push concluído com sucesso."
}

# --- Execução Principal ---
update_docs
generate_linkedin_post
perform_git_operations

echo ">>> Processo de 'RUpload' finalizado."
