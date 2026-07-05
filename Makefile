# Define o alvo padrão para 'help' quando 'make' é executado sem argumentos.
DEFAULT_GOAL := help

.PHONY: help up down logs status backup release scan

# Variável para o caminho do arquivo docker-compose, facilitando a manutenção.
COMPOSE_FILE := infra/docker-compose.yml

help:
	@echo "Comandos disponíveis para o projeto AXES Bank:"
	@echo "  make up      - Inicia os containers da aplicação em background."
	@echo "  make down    - Para e remove os containers da aplicação."
	@echo "  make logs    - Exibe e acompanha os logs dos containers."
	@echo "  make status  - Mostra o status atual dos containers."
	@echo "  make backup  - Executa o script de backup do banco de dados."
	@echo "  make scan    - Analisa o projeto, atualiza o roadmap e sugere o próximo passo."
	@echo "  make release - Inicia o ciclo de release de trabalho (docs, post, commit, push)."

up:
	@echo "Subindo containers..."
	@docker compose -f $(COMPOSE_FILE) up -d

down:
	@echo "Parando containers..."
	@docker compose -f $(COMPOSE_FILE) down

logs:
	@echo "Acompanhando logs..."
	@docker compose -f $(COMPOSE_FILE) logs -f

status:
	@echo "Status dos containers:"
	@docker compose -f $(COMPOSE_FILE) ps

backup:
	@echo "Executando o script de backup do banco de dados..."
	@bash scripts/backup_database.sh

release:
	@echo "Iniciando processo de RUpload..."
	@bash scripts/release_work.sh

scan:
	@echo "Iniciando scanner de projeto..."
	@bash scripts/project_scanner.sh
