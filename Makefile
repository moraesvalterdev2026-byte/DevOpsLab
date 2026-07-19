# Define 'help' como o alvo padrão (executado ao digitar apenas 'make')
.DEFAULT_GOAL := help

# Carrega variáveis do arquivo .env se ele existir, tornando-as disponíveis para o make e docker-compose.
# Isso resolve a necessidade de exportar manualmente as credenciais (IAM_USER, IAM_TOKEN).
ifneq (,$(wildcard ./.env))
    include .env
    export
endif

# Variável para o caminho do arquivo docker-compose, facilitando a manutenção.
COMPOSE_FILE := infra/docker-compose.yml

# Exporta a raiz do projeto para scripts, garantindo contexto de execução.
export PROJECT_ROOT := $(CURDIR)
.PHONY: help
help: ## Exibe esta mensagem de ajuda com os comandos disponíveis.
	@echo "Comandos disponíveis para o projeto AXES Bank:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

.PHONY: up down logs status backup release scan audit-ai

# --- Gerenciamento do Ambiente Docker ---
up: ## Inicia os containers da aplicação em background.
	@echo "Subindo containers..."
	@docker compose -f $(COMPOSE_FILE) up -d

down: ## Para e remove os containers da aplicação.
	@echo "Parando containers..."
	@docker compose -f $(COMPOSE_FILE) down

logs: ## Exibe e acompanha os logs de todos os containers.
	@echo "Acompanhando logs..."
	@docker compose -f $(COMPOSE_FILE) logs -f

status: ## Mostra o status atual dos containers (rodando, parado, etc.).
	@echo "Status dos containers:"
	@docker compose -f $(COMPOSE_FILE) ps

# --- Automações de Operação e Governança ---
backup: ## Executa o script de backup do banco de dados.
	@echo "Executando o script de backup do banco de dados..."
	@bash scripts/backup_database.sh

release: ## Executa o ciclo completo de release (auditoria, documentação, commit e push).
	@PROJECT_ROOT=$(CURDIR) bash $(CURDIR)/scripts/release_work.sh

scan: ## Analisa o projeto, atualiza o roadmap e sugere o próximo passo.
	@echo "Iniciando scanner de projeto..."
	@bash scripts/project_scanner.sh

audit-ai: ## Executa uma auditoria de governança em artefatos usando um agente de IA local.
	@echo "Iniciando auditoria com Agente de IA..."
	@bash scripts/ai_governance_audit.sh
