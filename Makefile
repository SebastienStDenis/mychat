COMPOSE = DOCKER_BUILDKIT=1 docker compose -f ./infra/dev/docker-compose.yml

.PHONY: help init install lint type test clean dc-test dc-up dc-logs dc-stop dc-down dc-build kind-up kind-down tilt-up tilt-down

help:
	@echo "Makefile commands:"
	@echo "  init     		- Initialize the development environment (env, hooks)"
	@echo "  install  		- Install dependencies for all services"
	@echo "  lint     		- Run linters on all services"
	@echo "  type	 		- Run type checks on all services"
	@echo "  test     		- Run unit tests locally"
	@echo "  clean    		- Clean up the development environment"
	@echo "  dc-test		- Run integration tests in containers"
	@echo "  dc-up			- Start the development docker compose stack"
	@echo "  dc-logs		- Follow the logs of all services"
	@echo "  dc-stop		- Stop services without removing containers"
	@echo "  dc-down		- Stop and remove containers, networks, volumes"
	@echo "  dc-build		- Build all Docker images"
	@echo "  kind-up		- Create a local Kubernetes cluster with kind and deploy nginx gateway fabric"
	@echo "  kind-down		- Delete the local Kubernetes cluster"
	@echo "  tilt-up		- Deploy local Kubernetes resources with Tilt"
	@echo "  tilt-down		- Remove local Kubernetes resources with Tilt"

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


kind-up:
	-kind create cluster --name mychat --config infra/k8s/kind/kind-config.yaml
	kubectl config set-context --current --namespace=mychat


kind-deps:
	kubectl apply -k infra/platform/gateway-api
	helm upgrade --install ngf oci://ghcr.io/nginx/charts/nginx-gateway-fabric \
		--namespace nginx-gateway \
		--create-namespace \
		--version 2.2.1 \
		-f infra/platform/kind/ngf-values.yaml


kind-init: -kind-up kind-deps


kind-down:
	kind delete cluster --name mychat


tilt-up:
	cd infra/k8s/kind && tilt up


tilt-down:
	cd infra/k8s/kind && tilt down


gke-deps:
	gcloud container clusters update mychat --location=us-central1 --gateway-api=standard
	kubectl apply -k infra/platform/gateway-api
	helm upgrade --install external-secrets oci://ghcr.io/external-secrets/charts/external-secrets \
		--namespace external-secrets \
		--create-namespace \
		--version 1.0.0 \
		--set installCRDs=true

gke-apply:
	kubectl apply -k infra/k8s/overlays/gke
