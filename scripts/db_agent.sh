#!/bin/bash
# Agente de Banco de Dados - Gerenciador de Migrations

set -euo pipefail

DB_CONTAINER="axes_db"
COMMAND="$1"
MIGRATION_NAME="${2:-}"

case "$COMMAND" in
  create)
    if [ -z "$MIGRATION_NAME" ]; then
        echo "Erro: O nome da migration é obrigatório para o comando 'create'."
        echo "Uso: bash scripts/db_agent.sh create <nome_da_migration>"
        exit 1
    fi
    MIGRATION_FILE="migrations/$(date +%Y%m%d%H%M%S)_${MIGRATION_NAME}.sql"
    mkdir -p "$(dirname "$MIGRATION_FILE")"
    echo "-- Migration: ${MIGRATION_NAME}" > "$MIGRATION_FILE"
    echo "-- Created at: $(date)" >> "$MIGRATION_FILE"
    echo "" >> "$MIGRATION_FILE"
    echo "✔ Migration em branco '${MIGRATION_FILE}' criada."
    ;;
  
  apply)
    echo "Aplicando todas as migrations pendentes em 'migrations/'..."
    for f in migrations/*.sql; do
      echo "Aplicando $f..."
      docker exec -i "$DB_CONTAINER" psql -U "${DB_USER:-axes_user}" -d "${DB_NAME:-axes_db}" < "$f"
    done
    echo "✔ Migrations aplicadas com sucesso."
    ;;

  *)
    echo "Comando inválido. Uso: bash scripts/db_agent.sh [create|apply] [nome_da_migration]"
    exit 1
    ;;
esac