SRC_DIR     	:= src
APP_MODULE  	:= api.main:app
TEST_DIR    	:= tests
ENV_FILE		:= ../../infra/dev/.env

POETRY      	:= poetry
POETRY_RUN  	:= $(POETRY) run

define LOAD_ENV
set -a; \
if [ -f "$(ENV_FILE)" ]; then . "$(ENV_FILE)"; fi; \
set +a
endef

.PHONY: help lock install update type test run clean

help:
	@echo "  lock      - Generate the lock file"
	@echo "  install   - Install project dependencies"
	@echo "  update    - Update dependencies to their latest compatible versions"
	@echo "  type      - Run mypy on the source code"
	@echo "  test      - Run pytest on the tests"
	@echo "  run       - Run the FastAPI app with uvicorn in reload mode"
	@echo "  clean     - Remove virtualenv and cache files"

lock:
	$(POETRY) lock

install:
	$(POETRY) install

update:
	$(POETRY) update

type:
	$(POETRY_RUN) mypy $(SRC_DIR)

test:
	@$(LOAD_ENV); \
	$(POETRY_RUN) pytest $(TEST_DIR) -q

run:
	@$(LOAD_ENV); \
	$(POETRY_RUN) uvicorn $(APP_MODULE) --app-dir $(SRC_DIR) --host 0.0.0.0 --port 3001 --reload

clean:
	$(POETRY) env remove --all
	rm -rf .mypy_cache .pytest_cache
	find . -type d -name "__pycache__" -exec rm -rf {} +
	find . -type d -name ".pytest_cache" -exec rm -rf {} +
