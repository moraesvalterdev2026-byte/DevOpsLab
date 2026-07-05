#!/bin/bash
#
# LAB 02 - Linux Administration
# Script para configurar a rotina de backup automatizada (cron job).
#
# Objetivo: Adicionar uma entrada no crontab do usuário para executar
# o script de backup diariamente.
#
set -euo pipefail

# --- Variáveis ---
# Caminho absoluto para o script de backup. $(cd ...) resolve o caminho real do script.
SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/backup_database.sh"
JOB_COMMENT="# AXES Bank Backup Job"
# Executar todo dia à 1 da manhã.
CRON_SCHEDULE="0 1 * * *"

# --- Lógica ---

echo ">>> Iniciando configuração do cron job para o backup do AXES Bank..."

# 1. Garante que o script de backup seja executável.
echo "Garantindo que o script ${SCRIPT_PATH} seja executável..."
chmod +x "${SCRIPT_PATH}"

# 2. Define o comando completo a ser adicionado no crontab.
CRON_JOB="${CRON_SCHEDULE} ${SCRIPT_PATH}"

# 3. Verifica se o job já existe no crontab para evitar duplicatas.
# O comando `crontab -l` lista os jobs. `grep -Fq` busca pela string exata em modo silencioso.
if (crontab -l 2>/dev/null | grep -Fq -- "${CRON_JOB}"); then
    echo "O cron job para o backup já está configurado. Nenhuma ação necessária."
else
    echo "Adicionando o seguinte cron job:"
    echo "${CRON_JOB}"
    # Adiciona o job ao crontab do usuário.
    # `(crontab -l 2>/dev/null; echo "${JOB_COMMENT}"; echo "${CRON_JOB}")` cria uma lista com os jobs atuais e o novo.
    # `| crontab -` instala essa nova lista.
    (crontab -l 2>/dev/null; echo "${JOB_COMMENT}"; echo "${CRON_JOB}") | crontab -
    echo "Cron job configurado com sucesso!"
fi

echo ">>> Verificação do crontab atual:"
crontab -l