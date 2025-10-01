.PHONY: help install dev build start lint clean

help:
	@echo "  make install   - Install dependencies using npm ci"
	@echo "  make dev       - Run Next.js in development mode with hot reload"
	@echo "  make build     - Build the Next.js app for production"
	@echo "  make start     - Start the Next.js app in production mode"
	@echo "  make lint      - Run Next.js linting"
	@echo "  make clean     - Remove build artifacts and node_modules"

install:
	npm ci

dev:
	npm run dev

build:
	npm run build

start:
	npm run start

lint:
	npm run lint

clean:
	rm -rf .next node_modules