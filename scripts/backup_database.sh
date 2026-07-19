#!/bin/bash
#
# LAB 02 - Linux Administration
# Script para Backup Automatizado do Banco de Dados PostgreSQL (AXES Bank)
#
# Objetivo: Realizar o dump do banco de dados que está rodando em um container Docker,
# comprimir o resultado e gerenciar a retenção de backups antigos.
#

# --- Configuração de Segurança do Script ---
# 'set -e': Encerra o script se um comando falhar.
# 'set -u': Trata variáveis não definidas como um erro.
# 'set -o pipefail': Garante que o status de saída de um pipeline seja o do último comando que falhou.
set -euo pipefail

# --- Variáveis de Configuração ---
# Nome do container Docker onde o PostgreSQL está rodando.
DB_CONTAINER="axes_db"

# Nome do banco de dados a ser backupeado.
DB_NAME="axes_db"

# Usuário do banco de dados (deve ter permissões de leitura).
DB_USER="${DB_USER:-axes_user}"

# Senha do banco de dados. Carrega da variável de ambiente ou usa um padrão.
DB_PASSWORD="${DB_PASSWORD:-axes_pass}"

# Diretório onde os backups serão armazenados.
BACKUP_DIR="/home/moraes/EngDevOps/DevOpsLab/backups/postgres"

# Arquivo de log para registrar as operações de backup.
LOG_FILE="/home/moraes/EngDevOps/DevOpsLab/logs/backup.log"

# Formato do nome do arquivo de backup com data e hora.
DATE_FORMAT=$(date "+%Y-%m-%d_%H-%M-%S")
BACKUP_FILE="${BACKUP_DIR}/${DB_NAME}_${DATE_FORMAT}.sql.gz"

# Política de Retenção: Número de dias que os backups devem ser mantidos.
RETENTION_DAYS=7

# --- Funções ---

# Função para registrar mensagens com timestamp no console e no arquivo de log.
log_message() {
    local message="$1"
    echo "$(date "+%Y-%m-%d %H:%M:%S") - ${message}" | tee -a "${LOG_FILE}"
}

# --- Execução do Backup ---

log_message ">>> INICIANDO processo de backup para o banco de dados '${DB_NAME}'..."

# 1. Garante que os diretórios de backup e log existam.
mkdir -p "${BACKUP_DIR}"
mkdir -p "$(dirname "${LOG_FILE}")"

# 2. Executa o pg_dump dentro do container, comprime com gzip e salva no arquivo.
log_message "Criando dump do banco e comprimindo para: ${BACKUP_FILE}"

# A variável PGPASSWORD é usada pelo pg_dump para autenticação.
# O uso de 'docker exec' com a variável de ambiente garante que a senha não seja exposta
# na lista de processos do sistema (command line).
if docker exec -t -e PGPASSWORD="${DB_PASSWORD}" "${DB_CONTAINER}" pg_dump -U "${DB_USER}" -d "${DB_NAME}" --no-password | gzip > "${BACKUP_FILE}"; then
    log_message "Backup do banco de dados criado com sucesso."
else
    # A verificação de falha é explícita para logging, embora 'set -e' já interrompa o script.
    log_message "ERRO: Falha ao criar o dump do banco de dados '${DB_NAME}'."
    exit 1
fi

# 3. Limpa backups antigos com base na política de retenção.
log_message "Aplicando política de retenção de ${RETENTION_DAYS} dias em '${BACKUP_DIR}'..."
find "${BACKUP_DIR}" -type f -name "*.sql.gz" -mtime +${RETENTION_DAYS} -exec rm {} \;

log_message ">>> PROCESSO DE BACKUP CONCLUÍDO COM SUCESSO!"
log_message "Status atual do diretório de backups:"
ls -lh "${BACKUP_DIR}" | while read -r line; do log_message "$line"; done
