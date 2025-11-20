# Peekaping Local Development

This directory contains Docker Compose configuration for running Peekaping locally.

## Quick Start

```bash
# Copy environment variables
cp .env.example .env

# Start all services
docker compose up -d

# Check status
docker compose ps

# View logs
docker compose logs -f

# Stop services
docker compose down
```

## Access

Once running, Peekaping will be available at:
- **Web Interface**: http://localhost:8383
- **API**: http://localhost:8383/api/

## Services

- **redis**: Message broker for microservices
- **migrate**: Database migrations (runs once)
- **api**: REST API server (port 8034 internal)
- **producer**: Job scheduler for monitoring tasks
- **worker**: Executes monitoring checks
- **ingester**: Processes monitoring results
- **web**: Frontend SPA
- **gateway**: Nginx reverse proxy (port 8383 external)

## Data Persistence

Data is stored in `./.data/sqlite` directory. To reset:

```bash
docker compose down -v
rm -rf .data
docker compose up -d
```

## Configuration

Edit `.env` file to customize:
- **Version pinning** (`PEEKAPING_VERSION`) - Pin to specific version for stability
- Database settings
- Timezone
- Client URL
- Server port

### Version Management

```bash
# Production (recommended)
PEEKAPING_VERSION=v1.2.3

# Development
PEEKAPING_VERSION=latest
```

**Upgrading**:
```bash
# Update version in .env
echo "PEEKAPING_VERSION=v1.2.3" >> .env

# Pull new images and restart
docker compose pull && docker compose up -d
```

Check releases: https://github.com/0xfurai/peekaping/releases

## Troubleshooting

### Check service health
```bash
docker compose ps
```

### View specific service logs
```bash
docker compose logs -f api
docker compose logs -f worker
```

### Restart a service
```bash
docker compose restart api
```

### Clean restart
```bash
docker compose down
docker compose up -d
```
