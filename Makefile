COMPOSE = docker compose -f ./infra/dev/docker-compose.yml

.PHONY: help up down build logs ps restart test

help:
	@echo "Makefile commands:"
	@echo "  up       - Start the development environment"
	@echo "  down     - Stop the development environment"
	@echo "  build    - Build the Docker images"
	@echo "  logs     - Follow the logs of all services"
	@echo "  ps       - List the running services"
	@echo "  restart  - Restart the development environment"
	@echo "  test     - Run tests in containers"

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
# in reality running tests in containers is only useful for integration/e2e tests, unit tests should be run locally
test-api:
	$(COMPOSE) --project-name test run --rm api-test
	$(COMPOSE) --project-name test down -v

test: test-api