#!/bin/bash

# ==============================================================================
# Automated Docker Setup Script for Acquisitions API
# ==============================================================================
# This script automates the entire Docker setup process for both development
# and production environments.
#
# Usage:
#   ./setup-docker.sh                 # Interactive setup
#   ./setup-docker.sh dev             # Setup development only
#   ./setup-docker.sh prod            # Setup production only
#   ./setup-docker.sh all             # Setup both dev and prod
#   ./setup-docker.sh --help          # Show this help
#
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../../" && pwd)"
DEV_ENV_FILE="${PROJECT_ROOT}/.env.development"
PROD_ENV_FILE="${PROJECT_ROOT}/.env.production"
DEV_EXAMPLE="${PROJECT_ROOT}/.env.development.example"
PROD_EXAMPLE="${PROJECT_ROOT}/.env.production.example"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# ==============================================================================
# Helper Functions
# ==============================================================================

print_header() {
    echo -e "\n${BLUE}════════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}$1${NC}"
    echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_section() {
    echo -e "\n${CYAN}→${NC} $1"
}

pause_input() {
    echo -ne "${YELLOW}Press Enter to continue...${NC}"
    read -r
}

# Check if Docker is installed
check_docker() {
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed"
        echo "Please install Docker Desktop from: https://www.docker.com/products/docker-desktop"
        exit 1
    fi
    print_success "Docker is installed ($(docker --version))"
}

# Check if Docker Compose is installed
check_docker_compose() {
    if ! command -v docker compose &> /dev/null; then
        print_error "Docker Compose is not installed"
        echo "Please install Docker Desktop which includes Compose"
        exit 1
    fi
    print_success "Docker Compose is installed ($(docker compose version | head -1))"
}

# Show help
show_help() {
    cat << EOF
${GREEN}Automated Docker Setup for Acquisitions API${NC}

${CYAN}Usage:${NC}
  $0 [COMMAND]

${CYAN}Commands:${NC}
  (none)        Interactive setup - you'll be prompted
  dev           Setup development environment only
  prod          Setup production environment only
  all           Setup both development and production
  start         Start development environment
  stop          Stop all environments
  clean         Remove all containers and volumes
  status        Show setup status
  help          Show this help message

${CYAN}Examples:${NC}
  $0                    # Interactive mode
  $0 dev                # Setup development
  $0 prod               # Setup production
  $0 all                # Setup both
  $0 start              # Start dev environment
  $0 stop               # Stop all

${CYAN}What this script does:${NC}
  1. Checks Docker and Docker Compose installation
  2. Creates environment files from examples (.env.development, .env.production)
  3. Prompts for Neon API credentials (development only)
  4. Validates configuration
  5. Builds Docker images
  6. Optionally starts the environment

${CYAN}Documentation:${NC}
  Full Setup:  DOCKER_SETUP.md
  Quick Start: QUICK_START.md
  Commands:    make help

EOF
}

# ==============================================================================
# Environment Setup Functions
# ==============================================================================

setup_development() {
    print_header "🔧 Setting Up Development Environment"

    # Create .env.development if it doesn't exist
    if [ ! -f "$DEV_ENV_FILE" ]; then
        print_section "Creating .env.development from template..."
        cp "$DEV_EXAMPLE" "$DEV_ENV_FILE"
        print_success "Created .env.development"
    else
        print_warn ".env.development already exists (skipping)"
    fi

    # Ask about Neon API credentials
    print_section "Neon API Configuration (Optional for Ephemeral Branches)"
    echo -e "${YELLOW}You can skip this for basic development.${NC}"
    read -p "Do you want to add Neon API credentials? (y/N): " -r add_neon_creds

    if [[ "$add_neon_creds" =~ ^[Yy]$ ]]; then
        print_info "Get these from: https://console.neon.tech → Account Settings → API Keys"

        read -p "Enter NEON_API_KEY: " neon_api_key
        read -p "Enter NEON_PROJECT_ID: " neon_project_id

        # Update .env.development
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS requires -i with extension
            sed -i '' "s|NEON_API_KEY=.*|NEON_API_KEY=$neon_api_key|" "$DEV_ENV_FILE"
            sed -i '' "s|NEON_PROJECT_ID=.*|NEON_PROJECT_ID=$neon_project_id|" "$DEV_ENV_FILE"
        else
            # Linux
            sed -i "s|NEON_API_KEY=.*|NEON_API_KEY=$neon_api_key|" "$DEV_ENV_FILE"
            sed -i "s|NEON_PROJECT_ID=.*|NEON_PROJECT_ID=$neon_project_id|" "$DEV_ENV_FILE"
        fi

        print_success "Updated NEON API credentials in .env.development"
    fi

    print_info "Development environment file: $DEV_ENV_FILE"
    echo ""
}

setup_production() {
    print_header "🏭 Setting Up Production Environment"

    # Create .env.production if it doesn't exist
    if [ ! -f "$PROD_ENV_FILE" ]; then
        print_section "Creating .env.production from template..."
        cp "$PROD_EXAMPLE" "$PROD_ENV_FILE"
        print_success "Created .env.production"
    else
        print_warn ".env.production already exists (skipping)"
    fi

    # Ask about Neon Cloud URL
    print_section "Neon Cloud Database Configuration"
    echo -e "${YELLOW}You need a Neon Cloud database connection string.${NC}"
    read -p "Do you want to add your Neon Cloud URL now? (y/N): " -r add_neon_url

    if [[ "$add_neon_url" =~ ^[Yy]$ ]]; then
        print_info "Get this from: https://console.neon.tech → Connection Strings"
        echo "Format: postgres://user:password@ep-xxxx.neon.tech/dbname?sslmode=require"

        read -p "Enter DATABASE_URL: " database_url

        # Update .env.production
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' "s|DATABASE_URL=.*|DATABASE_URL=$database_url|" "$PROD_ENV_FILE"
        else
            sed -i "s|DATABASE_URL=.*|DATABASE_URL=$database_url|" "$PROD_ENV_FILE"
        fi

        print_success "Updated DATABASE_URL in .env.production"
    else
        print_warn "Remember to add DATABASE_URL to .env.production before running production"
    fi

    print_info "Production environment file: $PROD_ENV_FILE"
    echo ""
}

# ==============================================================================
# Docker Build Functions
# ==============================================================================

build_development() {
    print_header "🏗️  Building Development Docker Image"
    print_section "This will build the development image (first time takes 2-3 minutes)"

    if docker compose -f "${PROJECT_ROOT}/docker-compose.dev.yml" build app; then
        print_success "Development image built successfully"
    else
        print_error "Failed to build development image"
        return 1
    fi
    echo ""
}

build_production() {
    print_header "🏗️  Building Production Docker Image"
    print_section "This will build the production image (optimized, first time takes 2-3 minutes)"

    if docker compose -f "${PROJECT_ROOT}/docker-compose.prod.yml" build app; then
        print_success "Production image built successfully"
    else
        print_error "Failed to build production image"
        return 1
    fi
    echo ""
}

# ==============================================================================
# Validation Functions
# ==============================================================================

validate_development() {
    print_section "Validating development configuration..."

    if [ ! -f "$DEV_ENV_FILE" ]; then
        print_error ".env.development not found"
        return 1
    fi

    if docker compose -f "${PROJECT_ROOT}/docker-compose.dev.yml" config > /dev/null 2>&1; then
        print_success "Development configuration is valid"
        return 0
    else
        print_error "Development configuration is invalid"
        return 1
    fi
}

validate_production() {
    print_section "Validating production configuration..."

    if [ ! -f "$PROD_ENV_FILE" ]; then
        print_error ".env.production not found"
        return 1
    fi

    if docker compose -f "${PROJECT_ROOT}/docker-compose.prod.yml" config > /dev/null 2>&1; then
        print_success "Production configuration is valid"
        return 0
    else
        print_error "Production configuration is invalid"
        return 1
    fi
}

# ==============================================================================
# Status Function
# ==============================================================================

show_status() {
    print_header "📊 Setup Status"

    echo -e "${CYAN}Docker Installation:${NC}"
    if command -v docker &> /dev/null; then
        print_success "Docker installed ($(docker --version))"
    else
        print_error "Docker not installed"
    fi

    echo -e "\n${CYAN}Development Environment:${NC}"
    if [ -f "$DEV_ENV_FILE" ]; then
        print_success ".env.development exists"
    else
        print_warn ".env.development not found"
    fi

    if validate_development 2>/dev/null; then
        print_success "Configuration valid"
    else
        print_warn "Configuration needs setup"
    fi

    echo -e "\n${CYAN}Production Environment:${NC}"
    if [ -f "$PROD_ENV_FILE" ]; then
        print_success ".env.production exists"
    else
        print_warn ".env.production not found"
    fi

    if validate_production 2>/dev/null; then
        print_success "Configuration valid"
    else
        print_warn "Configuration needs setup"
    fi

    echo -e "\n${CYAN}Docker Images:${NC}"
    if docker images | grep -q "node.*20.*alpine"; then
        print_success "Base images available"
    else
        print_warn "Base images need to be pulled"
    fi

    echo -e "\n${CYAN}Running Containers:${NC}"
    local dev_count=$(docker ps 2>/dev/null | grep -c "acquisitions-app-dev" || true)
    local prod_count=$(docker ps 2>/dev/null | grep -c "acquisitions-app-prod" || true)

    if [ "$dev_count" -gt 0 ]; then
        print_success "Development container running"
    else
        print_info "Development container not running"
    fi

    if [ "$prod_count" -gt 0 ]; then
        print_success "Production container running"
    else
        print_info "Production container not running"
    fi

    echo ""
}

# ==============================================================================
# Action Functions
# ==============================================================================

start_development() {
    print_header "🚀 Starting Development Environment"

    if ! validate_development; then
        print_error "Development configuration is invalid"
        return 1
    fi

    print_section "Starting app and Neon Local containers..."
    docker compose --env-file "$DEV_ENV_FILE" -f "${PROJECT_ROOT}/docker-compose.dev.yml" up --build
}

stop_all() {
    print_header "🛑 Stopping All Environments"

    print_section "Stopping development..."
    if docker compose -f "${PROJECT_ROOT}/docker-compose.dev.yml" ps | grep -q "acquisitions"; then
        docker compose -f "${PROJECT_ROOT}/docker-compose.dev.yml" down
        print_success "Development stopped"
    else
        print_info "Development not running"
    fi

    print_section "Stopping production..."
    if docker compose -f "${PROJECT_ROOT}/docker-compose.prod.yml" ps | grep -q "acquisitions"; then
        docker compose -f "${PROJECT_ROOT}/docker-compose.prod.yml" down
        print_success "Production stopped"
    else
        print_info "Production not running"
    fi

    echo ""
}

clean_all() {
    print_header "🧹 Cleaning Up Docker Resources"

    print_warn "This will remove containers, networks, and volumes"
    read -p "Are you sure? (y/N): " -r confirm

    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        print_info "Cleanup cancelled"
        return 0
    fi

    print_section "Removing development environment..."
    docker compose -f "${PROJECT_ROOT}/docker-compose.dev.yml" down -v 2>/dev/null || true
    print_success "Development cleaned"

    print_section "Removing production environment..."
    docker compose -f "${PROJECT_ROOT}/docker-compose.prod.yml" down -v 2>/dev/null || true
    print_success "Production cleaned"

    echo ""
}

# ==============================================================================
# Interactive Mode
# ==============================================================================

interactive_mode() {
    print_header "🎯 Interactive Docker Setup"

    while true; do
        echo -e "${CYAN}What would you like to do?${NC}"
        echo ""
        echo "1) Setup development environment"
        echo "2) Setup production environment"
        echo "3) Setup both"
        echo "4) Build Docker images"
        echo "5) Start development environment"
        echo "6) Stop all environments"
        echo "7) Show setup status"
        echo "8) Clean up everything"
        echo "9) Exit"
        echo ""

        read -p "Choose an option (1-9): " -r choice

        case $choice in
            1) setup_development ;;
            2) setup_production ;;
            3)
                setup_development
                setup_production
                ;;
            4)
                build_development
                build_production
                ;;
            5) start_development ;;
            6) stop_all ;;
            7) show_status ;;
            8) clean_all ;;
            9)
                print_success "Setup script completed"
                exit 0
                ;;
            *)
                print_error "Invalid option"
                ;;
        esac
    done
}

# ==============================================================================
# Main Script
# ==============================================================================

main() {
    # Show banner
    clear
    echo -e "${CYAN}"
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║     Automated Docker Setup: Acquisitions API + Neon DB        ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"

    # Check prerequisites
    print_section "Checking prerequisites..."
    check_docker
    check_docker_compose
    print_success "All prerequisites met\n"

    # Handle command line arguments
    case "${1:-}" in
        help|--help|-h)
            show_help
            exit 0
            ;;
        dev)
            setup_development
            build_development
            validate_development && print_success "Development setup complete!"
            ;;
        prod)
            setup_production
            build_production
            validate_production && print_success "Production setup complete!"
            ;;
        all)
            setup_development
            setup_production
            build_development
            build_production
            print_success "Development and production setup complete!"
            ;;
        start)
            start_development
            ;;
        stop)
            stop_all
            ;;
        status)
            show_status
            ;;
        clean)
            clean_all
            ;;
        "")
            interactive_mode
            ;;
        *)
            print_error "Unknown command: $1"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

# Run main function
main "$@"
