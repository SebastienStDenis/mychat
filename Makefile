COMPOSE = docker compose -f ./infra/dev/docker-compose.yml

.PHONY: help init up down build logs ps restart integration-test install type test clean

help:
	@echo "Makefile commands:"
	@echo "  init     			- Initialize the development environment"
	@echo "  up       			- Start the development environment"
	@echo "  down     			- Stop the development environment"
	@echo "  build    			- Build the Docker images"
	@echo "  logs     			- Follow the logs of all services"
	@echo "  ps       			- List the running services"
	@echo "  restart  			- Restart the development environment"
	@echo "  integration-test   - Run integration tests in containers"
	@echo "  install  			- Install dependencies for all services"
	@echo "  type	 			- Run type checks on all services"
	@echo "  test     			- Run unit tests locally"
	@echo "  clean    			- Clean up the development environment"

init:
	@if [ ! -f ./infra/dev/.env ]; then \
		cp ./infra/dev/.env.example ./infra/dev/.env; \
		echo "⚠️ Created infra/dev/.env, please update it with the required values."; \
	else \
		echo "✅ infra/dev/.env already exists, skipping creation."; \
	fi
	pipx install pre-commit
	pipx run pre-commit install

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

# bring up test-api container and its dependencies, specifying project name to avoid conflicts with dev environment
integration-test:
	$(COMPOSE) --project-name test run -T --rm api-test
	$(COMPOSE) --project-name test down -v

install: down
	$(MAKE) -C services/api install
	cd services/web && npm run predev

type: down
	$(MAKE) -C services/api type
	cd services/web && npm run type

test:
	$(MAKE) -C services/api test

clean:
	$(MAKE) -C services/api clean
	cd services/web && npm run clean
