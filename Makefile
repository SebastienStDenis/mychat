COMPOSE = DOCKER_BUILDKIT=1 docker compose -f ./infra/dev/docker-compose.yml

.PHONY: help init install lint type test clean dc-test dc-up dc-logs dc-stop dc-down dc-build

help:
	@echo "Makefile commands:"
	@echo "  init     	- Initialize the development environment (env, hooks)"
	@echo "  install  	- Install dependencies for all services"
	@echo "  lint     	- Run linters on all services"
	@echo "  type	 	- Run type checks on all services"
	@echo "  test     	- Run unit tests locally"
	@echo "  clean    	- Clean up the development environment"
	@echo "  dc-test	- Run integration tests in containers"
	@echo "  dc-up		- Start the development docker compose stack"
	@echo "  dc-logs	- Follow the logs of all services"
	@echo "  dc-stop	- Stop services without removing containers"
	@echo "  dc-down	- Stop and remove containers, networks, volumes"
	@echo "  dc-build	- Build all Docker images"

init:
	@if [ ! -f ./infra/dev/.env ]; then \
		cp ./infra/dev/.env.example ./infra/dev/.env; \
		echo "⚠️ Created infra/dev/.env, please update it."; \
	else \
		echo "infra/dev/.env already exists, skipping."; \
	fi
	pipx ensurepath
	pipx install "poetry==2.2.*"
	pipx install "pre-commit==4.3.*"
	pre-commit install

install:
	$(MAKE) -C services/api install
	cd services/web && npm run predev

lint:
	pre-commit run --all-files

type:
	$(MAKE) -C services/api type
	cd services/web && npm run type

test:
	$(MAKE) -C services/api test

clean:
	$(MAKE) -C services/api clean
	cd services/web && npm run clean

# Integration Tests for api service
# bring up test-api container and its dependencies, specifying project name to avoid conflicts with dev environment
dc-test:
	$(COMPOSE) --project-name test run -T --rm api-test
	$(COMPOSE) --project-name test down -v

dc-up:
	$(COMPOSE) up -d


dc-logs:
	$(COMPOSE) logs -f


dc-stop:
	$(COMPOSE) stop


dc-down:
	$(COMPOSE) down


dc-build:
	$(COMPOSE) build

k-init:
	kind create cluster --name mychat --config infra/k8s/kind-config.yaml

k-up:
	kubectl kustomize "https://github.com/nginx/nginx-gateway-fabric/config/crd/gateway-api/standard?ref=v2.2.1" | kubectl apply -f -
	helm install ngf oci://ghcr.io/nginx/charts/nginx-gateway-fabric --create-namespace -n nginx-gateway --set nginx.service.type=NodePort --set-json 'nginx.service.nodePorts=[{"port":31437,"listenerPort":80}]'
	kubectl apply -k infra/k8s/overlays/local

k-down:
	kubectl delete -k infra/k8s/overlays/local

k-clean:
	kind delete cluster --name mychat
