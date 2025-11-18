# Uptime Kuma Docker Compose

This Docker Compose configuration works for both local development and production deployment.

## Local Development

1. Copy the example environment file:
   ```bash
   cp .env.example .env
   ```

2. Start Uptime Kuma:
   ```bash
   docker-compose up -d
   ```

3. Access Uptime Kuma at: http://localhost:3001

4. Stop Uptime Kuma:
   ```bash
   docker-compose down
   ```

## Production Deployment

On the production VM, the docker-compose.yml is deployed via Ansible with these settings:
- `DATA_PATH=/mnt/uptime-kuma` (Hetzner volume mount point)
- Nginx reverse proxy configured for HTTPS
- Let's Encrypt SSL certificate
- Accessible at: https://uptime.ainsley.dev

## Data Persistence

- **Local**: Data is stored in `./data` directory
- **Production**: Data is stored on a 10GB Hetzner volume mounted at `/mnt/uptime-kuma`

## Updating Uptime Kuma

```bash
docker-compose pull
docker-compose up -d
```
