#!/bin/bash

# Matrix Server Management Script
# This script provides common operations for managing the Matrix server

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPOSE_FILE="$PROJECT_ROOT/docker-compose.yml"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Helper functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $*"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $*"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*"
}

# Check if Docker is running
check_docker() {
    if ! docker info > /dev/null 2>&1; then
        log_error "Docker is not running. Please start Docker and try again."
        exit 1
    fi
}

# Check if Docker Compose is available
check_compose() {
    if ! command -v docker-compose > /dev/null 2>&1; then
        log_error "Docker Compose is not installed or not in PATH."
        exit 1
    fi
}

# Validate configuration
validate_config() {
    log_info "Validating Docker Compose configuration..."
    if docker-compose -f "$COMPOSE_FILE" config > /dev/null 2>&1; then
        log_info "Configuration is valid"
        return 0
    else
        log_error "Configuration validation failed"
        return 1
    fi
}

# Start all services
start_all() {
    log_info "Starting all Matrix server services..."
    check_docker
    check_compose
    validate_config

    docker-compose -f "$COMPOSE_FILE" up -d
    log_info "All services started successfully"

    log_info "Services available at:"
    echo "  - Element Web: https://chat.${DOMAIN}"
    echo "  - Synapse Admin: https://admin.${DOMAIN}"
    echo "  - Traefik Dashboard: https://traefik.${DOMAIN}"
}

# Stop all services
stop_all() {
    log_info "Stopping all Matrix server services..."
    docker-compose -f "$COMPOSE_FILE" down
    log_info "All services stopped"
}

# View logs
view_logs() {
    local service="$1"
    if [ -z "$service" ]; then
        log_error "Please specify a service name"
        echo "Usage: $0 logs <service_name>"
        echo "Available services: db, homeserver, webchat, admin, proxy"
        exit 1
    fi

    log_info "Viewing logs for service: $service"
    docker-compose -f "$COMPOSE_FILE" logs -f "$service"
}

# Show status
show_status() {
    log_info "Matrix server status:"
    docker-compose -f "$COMPOSE_FILE" ps
}

# Backup data
backup_data() {
    local backup_dir="$PROJECT_ROOT/backups/$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$backup_dir"

    log_info "Creating backup in: $backup_dir"

    # Backup database
    log_info "Backing up database..."
    docker exec synapse-db pg_dump -U synapse synapse_db > "$backup_dir/database.sql"

    # Backup configuration
    log_info "Backing up configuration..."
    cp -r "$PROJECT_ROOT/config" "$backup_dir/"

    # Backup environment (without secrets)
    log_info "Backing up environment configuration..."
    cp "$PROJECT_ROOT/.env" "$backup_dir/.env.backup"

    log_info "Backup completed successfully"
    echo "Backup location: $backup_dir"
}

# Main menu
show_help() {
    cat << EOF
Matrix Server Management Script

Usage: $0 <command>

Commands:
  start       Start all services
  stop        Stop all services
  status      Show service status
  logs <svc>  View logs for a specific service
  validate    Validate Docker Compose configuration
  backup      Create a backup of data and configuration
  help        Show this help message

Examples:
  $0 start                    # Start all services
  $0 logs homeserver         # View Synapse logs
  $0 status                  # Check service status
  $0 backup                  # Create backup

EOF
}

# Main logic
main() {
    cd "$PROJECT_ROOT"

    case "${1:-help}" in
        start)
            start_all
            ;;
        stop)
            stop_all
            ;;
        status)
            show_status
            ;;
        logs)
            view_logs "$2"
            ;;
        validate)
            validate_config
            ;;
        backup)
            backup_data
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            log_error "Unknown command: $1"
            echo
            show_help
            exit 1
            ;;
    esac
}

main "$@"
