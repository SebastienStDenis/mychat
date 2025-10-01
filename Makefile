COMPOSE = docker compose -f ./infra/dev/docker-compose.yml

.PHONY: up down build logs ps restart

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