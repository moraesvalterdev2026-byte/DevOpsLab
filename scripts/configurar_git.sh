#!/bin/bash
# Script de Configuração de Identidade e SSH para DevOpsLab
# Objetivo: Padronizar o acesso ao Git e GitHub de forma segura.

set -eu

# 1. Identidade do Usuário (Git)
echo ">>> Configurando identidade do Git..."
git config --global user.name "moraesvalterdev2026-byte"
git config --global user.email "moraesvalter.dev2026@gmail.com"

# 2. Geração da chave SSH (se ainda não existir)
SSH_KEY="$HOME/.ssh/id_ed25519"
if [ ! -f "$SSH_KEY" ]; then
    echo ">>> Gerando nova chave SSH Ed25519..."
    ssh-keygen -t ed25519 -C "moraesvalter.dev2026@gmail.com" -f "$SSH_KEY" -N ""
else
    echo ">>> Chave SSH já existe em $SSH_KEY. Pulando geração."
fi

# 3. Exibir a chave pública para cadastro no GitHub
echo "---------------------------------------------------------"
echo "SUA CHAVE PÚBLICA (Copie a linha abaixo e cole no GitHub):"
echo "---------------------------------------------------------"
cat "$SSH_KEY.pub"
echo -e "\n---------------------------------------------------------"
echo "Siga os passos do seu manual para cadastrar esta chave."
