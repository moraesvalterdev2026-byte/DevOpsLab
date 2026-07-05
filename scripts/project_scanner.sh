#!/bin/bash
#
# Script de Análise e Planejamento (Project Scanner)
#
# Objetivo: Escanear o estado atual do projeto, comparar com o roadmap,
# atualizar o status dos laboratórios e sugerir o próximo passo estratégico.
#
set -euo pipefail

# --- Variáveis ---
ROADMAP_FILE="docs/roadmap.md"

# --- Funções ---

update_roadmap_status() {
    echo ">>> 🔎 Escaneando o projeto e atualizando o roadmap..."

    # LAB 02: Linux Administration
    if [[ -f "scripts/backup_database.sh" && -f "scripts/setup_cron.sh" ]]; then
        sed -i 's/\[ \] \*\*LAB 02: Linux Administration\*\*/\[x] \*\*LAB 02: Linux Administration\*\*/' "$ROADMAP_FILE"
        echo "✅ LAB 02: Linux Administration - Concluído (scripts de backup e cron encontrados)."
    fi

    # LAB 07: Continuous Integration
    # Procura por qualquer arquivo .yml ou .yaml dentro do diretório de workflows.
    if compgen -G ".github/workflows/*.y*ml" > /dev/null; then
        sed -i 's/\[ \] \*\*LAB 07: Continuous Integration\*\*/\[x] \*\*LAB 07: Continuous Integration\*\*/' "$ROADMAP_FILE"
        echo "✅ LAB 07: Continuous Integration - Concluído (arquivo de workflow encontrado)."
    fi

    # Adicionar futuras verificações para outros laboratórios aqui...

    echo ">>> Atualização do roadmap concluída."
}

suggest_next_step() {
    echo
    echo ">>> 🎯 Análise do Próximo Passo Estratégico (com base no Blueprint e Roadmap)"
    echo "--------------------------------------------------------------------------"

    # Encontra a primeira linha no roadmap que contém um item não concluído '[ ]'
    # e extrai o nome do Laboratório.
    NEXT_LAB=$(grep -m 1 '\[ \]' "$ROADMAP_FILE" | sed -n 's/.*\*LAB \([0-9]\{2\}: [A-Za-z ]*\)\*\*.*/LAB \1/p')

    if [ -n "$NEXT_LAB" ]; then
        echo "O próximo passo lógico no seu roadmap é:"
        echo
        echo "➡️  **${NEXT_LAB}**"
        echo
        echo "Este passo está alinhado com a 'Arquitetura Evolutiva' do seu blueprint, movendo o projeto para a próxima fase de maturidade."
    else
        echo "🎉 Parabéns! Todos os laboratórios do roadmap foram concluídos!"
    fi
    echo "--------------------------------------------------------------------------"
}

# --- Execução Principal ---

update_roadmap_status
suggest_next_step

echo ">>> Análise do projeto finalizada."