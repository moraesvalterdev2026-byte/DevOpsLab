# Define 'help' como o alvo padrão (executado ao digitar apenas 'make')
.DEFAULT_GOAL := ci

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

.PHONY: up down logs status backup release scan audit-ai test lint governance docs ci cache coverage frontend frontend-html frontend-css frontend-js frontend-validate edit

# --- Gerenciamento do Ambiente Docker ---
up: ## 🐳 Inicia os containers da aplicação em background.
	@echo "Subindo containers..."
	@docker compose -f $(COMPOSE_FILE) up -d

down: ## 🛑 Para e remove os containers da aplicação.
	@echo "Parando containers..."
	@docker compose -f $(COMPOSE_FILE) down

logs: ## 📜 Exibe e acompanha os logs de todos os containers.
	@echo "Acompanhando logs..."
	@docker compose -f $(COMPOSE_FILE) logs -f

status: ## 📊 Mostra o status atual dos containers (rodando, parado, etc.).
	@echo "Status dos containers:"
	@docker compose -f $(COMPOSE_FILE) ps

# --- Agentes de Automação (alinhados com CI) ---
cache: ## ⚡ Instala dependências com cache para acelerar builds
	@echo "Instalando dependências com cache..."
	@docker exec -it axes_app npm ci --prefer-offline

lint: ## 🧹 Executa o linter para verificar a qualidade do código.
	@echo "Executando linter..."
	@docker exec -it axes_app npm run lint

test: ## 🧪 Executa os testes dentro do container da aplicação.
	@echo "Rodando testes dentro do container axes_app..."
	@docker exec -it axes_app npm test

coverage: ## 📊 Executa testes com relatório de cobertura em HTML
	@echo "Rodando testes com cobertura..."
	@docker exec -it axes_app npm test -- --coverage --coverageReporters=html

frontend-html: ## 🌐 (Agente) Gera o HTML da página de login.
	@node scripts/frontend_html_agent.js

frontend-css: ## 🎨 (Agente) Gera o CSS para a página de login.
	@node scripts/frontend_css_agent.js

frontend-js: ## 📜 (Agente) Gera o JavaScript para a página de login.
	@node scripts/frontend_js_agent.js

frontend: frontend-html frontend-css frontend-js ## 🖼️ Executa todos os agentes de frontend para gerar o código.
	@echo "✔ Agente Frontend concluiu geração de código."

frontend-validate: ## ✅ Valida se as funções críticas do frontend estão ativas.
	@echo "Executando validação do frontend..."
	@bash scripts/frontend_validation.sh

# --- Agente de Banco de Dados ---
migrate-create: ## 🗄️ (Agente) Cria um novo arquivo de migration. Uso: make migrate-create CMD="<nome>"
	@bash scripts/db_agent.sh create $(CMD)

migrate-apply: ## 🗄️ (Agente) Aplica todas as migrations pendentes.
	@bash scripts/db_agent.sh apply

# --- Agente Inteligente de Edição ---
# Uso: make edit FILE=public/app.js CMD="Adicione uma validação de campo vazio"
edit: ## 🤖 Edita um arquivo usando o agente de IA.
	@node scripts/smart_agent.js $(FILE) "$(CMD)"
	@echo "Pulando lint temporariamente..." # Descomente o @make lint quando o npm install terminar

governance: ## 🔍 Executa a auditoria de governança com o agente de IA.
	@echo "Iniciando auditoria com Agente de IA..."
	@bash scripts/ai_governance_audit.sh

docs: ## 📄 (Placeholder) Atualiza a documentação do projeto.
	@echo "Executando agente de documentação..."
	@echo "Funcionalidade a ser implementada."

release: ## 🚀 Executa o ciclo completo de release (testes, auditoria, commit e push).
	@echo "Executando ciclo de release..."
	@make test
	@PROJECT_ROOT=$(CURDIR) bash $(CURDIR)/scripts/release_work.sh

backup: ## 💾 Executa o script de backup do banco de dados.
	@echo "Executando o script de backup do banco de dados..."
	@bash scripts/backup_database.sh

ci: lint test ## 🔄 Executa o pipeline local completo (lint e testes).
