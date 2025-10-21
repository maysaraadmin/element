# Matrix Server Project Structure

## Overview

This Matrix server project uses a clean, organized directory structure for easy management and maintenance.

## Directory Structure

```
matrix-server/
├── docker-compose.yml          # Main Docker Compose configuration
├── .env                        # Environment variables and configuration
├── README.md                   # Project documentation
│
├── config/                     # Configuration files for all services
│   ├── synapse/
│   │   └── homeserver.yaml     # Synapse server configuration
│   ├── traefik/
│   │   └── traefik-ssl.toml    # Traefik SSL/TLS configuration
│   ├── bridges/                # Bridge configurations
│   │   ├── telegram/           # Telegram bridge config
│   │   ├── facebook/           # Facebook bridge config
│   │   └── webhooks/           # Webhooks bridge config
│   └── bots/
│       └── maubot/             # Maubot configuration
│
├── data/                       # Persistent data directories
│   ├── postgres/               # PostgreSQL database files
│   ├── synapse-media/          # Synapse media files
│   ├── element-config.json     # Element web client config
│   └── db-init/               # Database initialization scripts
│
├── scripts/                    # Utility scripts
│   ├── setup.sh               # Initial setup script
│   ├── backup.sh              # Backup script
│   └── restore.sh             # Restore script
│
└── certs/                      # SSL/TLS certificates
    ├── fullchain.pem          # Let's Encrypt full chain certificate
    └── privkey.pem            # Private key
```

## Key Features

- **Organized Configuration**: All configuration files are in dedicated directories
- **Environment-Based**: Single `.env` file for all configuration
- **Traefik Proxy**: Modern reverse proxy with automatic SSL
- **Bridge Support**: Ready for popular messaging bridges
- **Scalable Structure**: Easy to add new services and features

## Quick Start

1. **Configure Environment**:
   ```bash
   # Edit .env file with your settings
   nano .env
   ```

2. **Start Services**:
   ```bash
   # Start all services
   docker-compose up -d

   # Or start individual services
   docker-compose up -d db homeserver webchat
   ```

3. **Access Services**:
   - **Element Web Client**: `https://chat.${DOMAIN}`
   - **Synapse Admin**: `https://admin.${DOMAIN}`
   - **Traefik Dashboard**: `https://traefik.${DOMAIN}` (with auth)

## Security Notes

- Change all default passwords in `.env`
- Use strong, unique secrets for production
- Regularly backup the `data/` directory
- Monitor logs for security events

## Development

- Configuration files are mounted as volumes for easy editing
- Services restart automatically when configs change
- Use `docker-compose logs -f [service]` for debugging
