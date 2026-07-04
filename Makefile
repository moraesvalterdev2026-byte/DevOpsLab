.PHONY: up down logs status

up:
	@echo "Subindo containers..."
	docker compose -f infra/docker-compose.yml up -d

down:
	@echo "Parando containers..."
	docker compose -f infra/docker-compose.yml down

logs:
	@echo "Acompanhando logs..."
	docker compose -f infra/docker-compose.yml logs -f

status:
	@echo "Status dos containers:"
	docker compose ps
