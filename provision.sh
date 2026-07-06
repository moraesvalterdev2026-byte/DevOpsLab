#!/bin/bash
#
# Script de Provisionamento para a Instância EC2 do AXES Bank
#
# Objetivo: Automatizar a configuração do servidor para rodar a aplicação
# containerizada após a criação da instância pelo Terraform.
#

# Garante que o script pare em caso de erro
set -e

echo ">>> Iniciando provisionamento do servidor..."

# Atualiza os pacotes do sistema
sudo yum update -y

# Instala o Docker
sudo yum install -y docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -a -G docker ec2-user

# Instala o Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Instala o Git
sudo yum install -y git

echo ">>> Provisionamento de dependências concluído."
echo ">>> A instância está pronta para hospedar a aplicação."