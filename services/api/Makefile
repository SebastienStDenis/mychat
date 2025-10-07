VENV        	:= .venv
SRC_DIR     	:= src
APP_MODULE  	:= api.main:app
TEST_DIR    	:= tests
ENV_FILE		:= ../../infra/dev/.env
ENV_EXAMPLE		:= ../../infra/dev/.env.example

REQ_IN      	:= requirements.in
REQ_TXT     	:= requirements.txt
REQ_DEV_IN  	:= requirements-dev.in
REQ_DEV_TXT 	:= requirements-dev.txt

PYTHON      	:= $(VENV)/bin/python
PIP         	:= $(PYTHON) -m pip
PIP_COMPILE 	:= $(VENV)/bin/pip-compile
PIP_SYNC    	:= $(VENV)/bin/pip-sync

UVICORN     	:= $(VENV)/bin/uvicorn
PYTEST      	:= $(VENV)/bin/pytest
BLACK       	:= $(VENV)/bin/black
MYPY        	:= $(VENV)/bin/mypy
RUFF        	:= $(VENV)/bin/ruff

COMPILE_ARGS 	:=  --generate-hashes --strip-extras --no-emit-index-url --no-emit-trusted-host

define LOAD_ENV
set -a; \
if [ -f "$(ENV_FILE)" ]; then . "$(ENV_FILE)"; fi; \
set +a
endef

.PHONY: help compile upgrade install type lint test run clean

help:
	@echo "  compile   - Compile requirements.in and requirements-dev.in into pinned txt files"
	@echo "  upgrade   - Upgrade all dependencies and recompile requirements"
	@echo "  install   - Sync project dependencies"
	@echo "  type      - Run mypy on the source code"
	@echo "  lint      - Run linters on the source code"
	@echo "  test      - Run pytest on the tests"
	@echo "  run       - Run the FastAPI app with uvicorn in reload mode"
	@echo "  clean     - Remove virtualenv and cache files"

$(VENV)/bin/activate:
	python3 -m venv $(VENV)
	$(PIP) install --upgrade pip pip-tools

compile: | $(VENV)/bin/activate
	$(PIP_COMPILE) $(COMPILE_ARGS) --output-file=$(REQ_TXT) $(REQ_IN)
	$(PIP_COMPILE) $(COMPILE_ARGS) --output-file=$(REQ_DEV_TXT) $(REQ_DEV_IN)

upgrade: | $(VENV)/bin/activate
	$(PIP_COMPILE) -U $(COMPILE_ARGS) --output-file=$(REQ_TXT) $(REQ_IN)
	$(PIP_COMPILE) -U $(COMPILE_ARGS) --output-file=$(REQ_DEV_TXT) $(REQ_DEV_IN)

install: | $(VENV)/bin/activate
	$(PIP_SYNC) $(REQ_TXT) $(REQ_DEV_TXT)
	$(PIP) install -e .

type: | $(VENV)/bin/activate
	$(MYPY) $(SRC_DIR)

lint: | $(VENV)/bin/activate
	$(RUFF) check --fix $(SRC_DIR) $(TEST_DIR)
	$(BLACK) $(SRC_DIR)

test: | $(VENV)/bin/activate
	@$(LOAD_ENV); \
	$(PYTEST) $(TEST_DIR) -q

run: | $(VENV)/bin/activate
	@$(LOAD_ENV); \
	$(UVICORN) $(APP_MODULE) --app-dir $(SRC_DIR) --host 0.0.0.0 --port 3001 --reload

clean:
	rm -rf $(VENV) .mypy_cache .pytest_cache
	find . -type d -name "__pycache__" -exec rm -rf {} +
	find . -type d -name ".pytest_cache" -exec rm -rf {} +
