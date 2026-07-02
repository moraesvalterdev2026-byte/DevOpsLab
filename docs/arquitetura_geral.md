# Arquitetura Geral: DevOpsLab (AXES Bank)

## 1. Visão de Infraestrutura
A plataforma adota o paradigma **Infrastructure as Code (IaC)**.
- **Ambiente:** Servidor Linux (AWS EC2).
- **Runtime:** Node.js em containers Docker.
- **Orquestração:** Docker Compose para gerenciamento de serviços.
- **Rede:** Exposição via porta 80.

## 2. Convenção de Estrutura de Diretórios
Para garantir a padronização e escalabilidade, o projeto segue a seguinte hierarquia:

| Diretório | Responsabilidade |
| :--- | :--- |
| **src/** | Código-fonte da aplicação (Node.js). |
| **infra/** | Definições de infraestrutura (Dockerfile, docker-compose.yml). |
| **configs/** | Arquivos de configuração não sensíveis. |
| **scripts/** | Automações, CI/CD e utilitários. |
| **docs/** | Documentação técnica e blueprints. |

## 3. Segurança e Persistência
- **Segurança:** Gestão de variáveis via  (ignorado pelo Git).
- **Persistência:** PostgreSQL (via container Docker).
