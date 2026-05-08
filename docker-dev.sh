#!/bin/bash

# ==============================================================================
# Development Docker Helper Script
# ==============================================================================
# Usage: ./docker-dev.sh [command]
# Commands:
#   start       - Start development environment
#   stop        - Stop development environment
#   logs        - View logs
#   shell       - Open shell in app container
#   migrate     - Run database migrations
#   generate    - Generate database schema
#   clean       - Remove containers and volumes
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${SCRIPT_DIR}/.env.development"
COMPOSE_FILE="${SCRIPT_DIR}/docker-compose.dev.yml"

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

echo_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

echo_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

# Check if .env.development exists
check_env_file() {
    if [ ! -f "$ENV_FILE" ]; then
        echo_error ".env.development not found!"
        echo_info "Creating from example..."
        cp "${SCRIPT_DIR}/.env.development.example" "$ENV_FILE"
        echo_warn "Please update .env.development with your Neon API credentials"
        exit 1
    fi
}

start_dev() {
    check_env_file
    echo_info "Starting development environment..."
    docker compose --env-file "$ENV_FILE" -f "$COMPOSE_FILE" up --build
}

stop_dev() {
    echo_info "Stopping development environment..."
    docker compose -f "$COMPOSE_FILE" down
}

logs_dev() {
    docker compose -f "$COMPOSE_FILE" logs -f "${1:-}"
}

shell_dev() {
    echo_info "Opening shell in app container..."
    docker compose -f "$COMPOSE_FILE" exec app sh
}

migrate_db() {
    echo_info "Running database migrations..."
    docker compose -f "$COMPOSE_FILE" exec app npm run db-migrate
}

generate_schema() {
    echo_info "Generating database schema..."
    docker compose -f "$COMPOSE_FILE" exec app npm run db-generate
}

clean_dev() {
    echo_warn "This will remove containers and volumes. Continue? (y/N)"
    read -r response
    if [ "$response" = "y" ] || [ "$response" = "Y" ]; then
        echo_info "Cleaning up development environment..."
        docker compose -f "$COMPOSE_FILE" down -v
        echo_info "Cleanup complete"
    else
        echo_info "Cancelled"
    fi
}

# Main command handler
case "${1:-start}" in
    start)
        start_dev
        ;;
    stop)
        stop_dev
        ;;
    logs)
        logs_dev "$2"
        ;;
    shell)
        shell_dev
        ;;
    migrate)
        migrate_db
        ;;
    generate)
        generate_schema
        ;;
    clean)
        clean_dev
        ;;
    *)
        echo_error "Unknown command: $1"
        echo ""
        echo "Available commands:"
        echo "  start       - Start development environment"
        echo "  stop        - Stop development environment"
        echo "  logs        - View logs (optional: app or neon-local)"
        echo "  shell       - Open shell in app container"
        echo "  migrate     - Run database migrations"
        echo "  generate    - Generate database schema"
        echo "  clean       - Remove containers and volumes"
        exit 1
        ;;
esac
