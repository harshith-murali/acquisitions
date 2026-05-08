.PHONY: help dev-start dev-stop dev-logs dev-shell dev-clean prod-start prod-stop prod-logs \
         db-migrate db-generate docker-build docker-clean health-check lint format

# Colors for output
GREEN := \033[0;32m
YELLOW := \033[0;33m
NC := \033[0m # No Color

help: ## Show this help message
	@echo "$(GREEN)Acquisitions Docker & Development Commands$(NC)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-20s$(NC) %s\n", $$1, $$2}'

# ==============================================================================
# Development Commands
# ==============================================================================

dev-start: ## Start development environment (app + Neon Local)
	@echo "$(GREEN)Starting development environment...$(NC)"
	@if [ ! -f .env.development ]; then \
		echo "$(YELLOW)Creating .env.development from example...$(NC)"; \
		cp .env.development.example .env.development; \
		echo "$(YELLOW)Please update .env.development with your Neon API credentials$(NC)"; \
		exit 1; \
	fi
	docker compose --env-file .env.development -f docker-compose.dev.yml up --build

dev-stop: ## Stop development environment
	@echo "$(GREEN)Stopping development environment...$(NC)"
	docker compose -f docker-compose.dev.yml down

dev-logs: ## View development logs (use: make dev-logs TAIL=100)
	docker compose -f docker-compose.dev.yml logs -f $(if $(TAIL),--tail=$(TAIL),)

dev-app-logs: ## View app logs only
	docker compose -f docker-compose.dev.yml logs -f app

dev-db-logs: ## View Neon Local logs only
	docker compose -f docker-compose.dev.yml logs -f neon-local

dev-shell: ## Open shell in app container
	@echo "$(GREEN)Opening shell in app container...$(NC)"
	docker compose -f docker-compose.dev.yml exec app sh

dev-clean: ## Remove development containers and volumes
	@echo "$(YELLOW)Removing development environment (this will delete data)...$(NC)"
	docker compose -f docker-compose.dev.yml down -v
	@echo "$(GREEN)Cleanup complete$(NC)"

# ==============================================================================
# Production Commands
# ==============================================================================

prod-start: ## Start production environment
	@echo "$(GREEN)Starting production environment...$(NC)"
	@if [ ! -f .env.production ]; then \
		echo "$(YELLOW)Creating .env.production from example...$(NC)"; \
		cp .env.production.example .env.production; \
		echo "$(YELLOW)Please update .env.production with your Neon Cloud URL$(NC)"; \
		exit 1; \
	fi
	docker compose --env-file .env.production -f docker-compose.prod.yml up -d
	@echo "$(GREEN)Production environment started in background$(NC)"
	@echo "Check status with: make health-check"

prod-stop: ## Stop production environment
	@echo "$(GREEN)Stopping production environment...$(NC)"
	docker compose -f docker-compose.prod.yml down

prod-logs: ## View production logs
	docker compose -f docker-compose.prod.yml logs -f app

prod-shell: ## Open shell in production container
	@echo "$(GREEN)Opening shell in production container...$(NC)"
	docker compose -f docker-compose.prod.yml exec app sh

# ==============================================================================
# Database Commands
# ==============================================================================

db-migrate: ## Run database migrations (development)
	@echo "$(GREEN)Running database migrations...$(NC)"
	docker compose -f docker-compose.dev.yml exec app npm run db-migrate
	@echo "$(GREEN)Migrations complete$(NC)"

db-generate: ## Generate database schema (development)
	@echo "$(GREEN)Generating database schema...$(NC)"
	docker compose -f docker-compose.dev.yml exec app npm run db-generate
	@echo "$(GREEN)Schema generation complete$(NC)"

db-studio: ## Open Drizzle Studio (development)
	@echo "$(GREEN)Opening Drizzle Studio...$(NC)"
	@echo "$(YELLOW)Studio will open at http://localhost:3001$(NC)"
	docker compose -f docker-compose.dev.yml exec app npx drizzle-kit studio

# ==============================================================================
# Docker & Build Commands
# ==============================================================================

docker-build: ## Build Docker images
	@echo "$(GREEN)Building Docker images...$(NC)"
	docker compose -f docker-compose.dev.yml build
	docker compose -f docker-compose.prod.yml build

docker-build-dev: ## Build development image
	docker compose -f docker-compose.dev.yml build --no-cache

docker-build-prod: ## Build production image
	docker compose -f docker-compose.prod.yml build --no-cache

docker-images: ## List Docker images
	@echo "$(GREEN)Docker images:$(NC)"
	docker images | grep acquisitions || echo "No acquisitions images found"

docker-ps: ## List running containers
	@echo "$(GREEN)Running containers:$(NC)"
	docker ps | grep acquisitions || echo "No acquisitions containers running"

docker-clean: ## Remove unused Docker resources
	@echo "$(YELLOW)Cleaning up Docker resources...$(NC)"
	docker system prune -f
	@echo "$(GREEN)Cleanup complete$(NC)"

# ==============================================================================
# Health & Status Commands
# ==============================================================================

health-check: ## Check application health
	@echo "$(GREEN)Checking application health...$(NC)"
	@curl -s http://localhost:3000/health | jq . || echo "$(YELLOW)Health check failed$(NC)"

status: ## Show container status
	@echo "$(GREEN)Container status:$(NC)"
	@docker compose -f docker-compose.dev.yml ps 2>/dev/null || echo "Development environment not running"
	@echo ""
	@docker compose -f docker-compose.prod.yml ps 2>/dev/null || echo "Production environment not running"

# ==============================================================================
# Code Quality Commands
# ==============================================================================

lint: ## Run ESLint
	@echo "$(GREEN)Running ESLint...$(NC)"
	npm run lint

lint-fix: ## Fix ESLint issues
	@echo "$(GREEN)Fixing ESLint issues...$(NC)"
	npm run lint:fix

format: ## Format code with Prettier
	@echo "$(GREEN)Formatting code...$(NC)"
	npm run format

format-check: ## Check code formatting
	@echo "$(GREEN)Checking code formatting...$(NC)"
	npm run format:check

# ==============================================================================
# Development Workflow Commands
# ==============================================================================

install: ## Install dependencies
	@echo "$(GREEN)Installing dependencies...$(NC)"
	npm ci

dev: ## Run development server (without Docker)
	@echo "$(GREEN)Starting development server...$(NC)"
	npm run dev

test: ## Run tests (if configured)
	@echo "$(GREEN)Running tests...$(NC)"
	npm test || echo "$(YELLOW)No tests configured$(NC)"

# ==============================================================================
# Documentation
# ==============================================================================

docs: ## Show Docker setup documentation
	@cat DOCKER_SETUP.md | less

docs-dev: ## Show development setup from docs
	@grep -A 50 "## Development Environment" DOCKER_SETUP.md | head -60

docs-prod: ## Show production setup from docs
	@grep -A 50 "## Production Environment" DOCKER_SETUP.md | head -60

# ==============================================================================
# Info & Debugging
# ==============================================================================

info: ## Show project information
	@echo "$(GREEN)Project Information:$(NC)"
	@echo "  Name: Acquisitions API"
	@echo "  Type: Node.js + Express + PostgreSQL"
	@echo "  Docker: Yes (Development + Production)"
	@echo "  Database: Neon (Local for dev, Cloud for prod)"
	@echo ""
	@echo "$(GREEN)Docker Compose Files:$(NC)"
	@echo "  Development: docker-compose.dev.yml"
	@echo "  Production:  docker-compose.prod.yml"
	@echo ""
	@echo "$(GREEN)Environment Files:$(NC)"
	@ls -1 .env* 2>/dev/null || echo "  No .env files found (run: make dev-start or make prod-start)"

env-check: ## Check environment files
	@echo "$(GREEN)Environment Files:$(NC)"
	@if [ -f .env.development ]; then echo "  ✓ .env.development"; else echo "  ✗ .env.development (missing)"; fi
	@if [ -f .env.production ]; then echo "  ✓ .env.production"; else echo "  ✗ .env.production (missing)"; fi
	@if [ -f .env.development.example ]; then echo "  ✓ .env.development.example"; else echo "  ✗ .env.development.example (missing)"; fi
	@if [ -f .env.production.example ]; then echo "  ✓ .env.production.example"; else echo "  ✗ .env.production.example (missing)"; fi

# ==============================================================================
# Advanced Commands
# ==============================================================================

shell-prod-db: ## Connect to production database (requires psql)
	@echo "$(YELLOW)Connecting to production database...$(NC)"
	@. .env.production 2>/dev/null && psql "$$DATABASE_URL" || echo "$(YELLOW).env.production not found$(NC)"

inspect-dev: ## Inspect development container
	docker inspect $$(docker compose -f docker-compose.dev.yml ps -q app) | jq .

version: ## Show version information
	@echo "$(GREEN)Version Information:$(NC)"
	@docker --version
	@docker compose --version
	@node --version
	@npm --version

# Default target
.DEFAULT_GOAL := help
