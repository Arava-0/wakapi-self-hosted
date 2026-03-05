# Variables
COMPOSE=docker compose
COMPOSE_FILE=docker-compose.yml

# Load environment variables
-include .env
export $(shell sed 's/=.*//' .env 2>/dev/null)

.PHONY: start stop restart build pull logs status delete app-shell db-shell health help

start: ## Start the stack (if not already running).
	$(COMPOSE) -f $(COMPOSE_FILE) -p $(PROJECT) up -d

stop: ## Stop the stack (without removing volumes).
	$(COMPOSE) -f $(COMPOSE_FILE) -p $(PROJECT) down

restart: ## Restart the stack.
	$(COMPOSE) -f $(COMPOSE_FILE) -p $(PROJECT) down
	$(COMPOSE) -f $(COMPOSE_FILE) -p $(PROJECT) up -d

build: ## Build (or rebuild) and start the stack.
	$(COMPOSE) -f $(COMPOSE_FILE) -p $(PROJECT) up -d --build

pull: ## Pull the latest images.
	$(COMPOSE) -f $(COMPOSE_FILE) -p $(PROJECT) pull

logs: ## Show logs for all services.
	$(COMPOSE) -f $(COMPOSE_FILE) -p $(PROJECT) logs -f

status: ## Show container status.
	$(COMPOSE) -f $(COMPOSE_FILE) -p $(PROJECT) ps

delete: ## Full reset (removes containers + volumes).
	$(COMPOSE) -f $(COMPOSE_FILE) -p $(PROJECT) down -v --remove-orphans

app-shell: ## Open a shell in the Wakapi container.
	$(COMPOSE) -f $(COMPOSE_FILE) -p $(PROJECT) exec $(WAKAPI_APP_CONTAINER) sh

db-shell: ## Open a shell in the Postgres container.
	$(COMPOSE) -f $(COMPOSE_FILE) -p $(PROJECT) exec $(WAKAPI_DB_CONTAINER) sh

health: ## Check if the app is responding.
	$(COMPOSE) -f $(COMPOSE_FILE) -p $(PROJECT) exec -T $(WAKAPI_APP_CONTAINER) wget -qO- http://localhost:3000/ >/dev/null && echo "OK" || (echo "KO"; exit 1)

help: ## Show available commands.
	@awk 'BEGIN {FS = ":.*##"; printf "\nAvailable commands:\n"} /^[a-zA-Z_-]+:.*##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)
