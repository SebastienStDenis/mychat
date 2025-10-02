COMPOSE = docker compose -f ./infra/dev/docker-compose.yml

.PHONY: help up down build logs ps restart

help:
	@echo "Makefile commands:"
	@echo "  up       - Start the development environment"
	@echo "  down     - Stop the development environment"
	@echo "  build    - Build the Docker images"
	@echo "  logs     - Follow the logs of all services"
	@echo "  ps       - List the running services"
	@echo "  restart  - Restart the development environment"

up:
	$(COMPOSE) up -d

down:
	$(COMPOSE) down

build:
	$(COMPOSE) build

logs:
	$(COMPOSE) logs -f

ps:
	$(COMPOSE) ps

restart: down up