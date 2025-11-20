# Peekaping Service

This Terraform module provisions infrastructure for Peekaping, a modern open-source uptime monitoring and status page service.

## Overview

Peekaping is deployed in microservice mode with the following components:
- **Redis**: Message broker for inter-service communication
- **API**: REST API server for backend operations
- **Producer**: Job scheduler for monitoring tasks
- **Worker**: Executes monitoring checks
- **Ingester**: Processes and stores monitoring results
- **Web**: Frontend SPA (Single Page Application)
- **Gateway**: Nginx reverse proxy for routing

## Infrastructure

### Hetzner Resources

- **Server**: CX23 (2 vCPU, 4GB RAM, ~€5.83/month)
- **Location**: Nuremberg, Germany (nbg1)
- **Volume**: 10GB persistent storage for SQLite database
- **OS**: Ubuntu with Docker

### Components

1. **Hetzner VM**: Provisioned using WebKit's server module
2. **Persistent Volume**: 10GB ext4 volume for database storage
3. **Ansible Inventory**: Auto-generated for deployment

## Configuration

### Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `hetzner_token` | Hetzner Cloud API token | (required) |
| `service_name` | Name of the service | `peekaping` |
| `server_type` | Hetzner server type | `cx23` |
| `location` | Hetzner datacenter location | `nbg1` |
| `volume_size` | Data volume size in GB | `10` |
| `domain` | Domain for the instance | `peekaping.ainsley.dev` |
| `admin_email` | Admin email for SSL certs | `hello@ainsley.dev` |
| `environment` | Environment name | `production` |
| `tags` | Resource tags | `["peekaping", "monitoring"]` |

### Customization

Configure your domain and settings in `terraform.tfvars`:

```hcl
# Required
hetzner_token = "your-token-here"

# Service domains (customize these!)
peekaping_domain = "monitoring.yourdomain.com"

# Optional overrides
admin_email = "admin@yourdomain.com"
environment = "production"
```

**Important**: After deployment, create a DNS A record pointing your domain to the server IP.

## Deployment Workflow

### 1. Initialize Terraform

```bash
make init
```

This initializes Terraform with the Backblaze B2 backend.

### 2. Plan Infrastructure Changes

```bash
make plan
```

Review the planned changes before applying.

### 3. Apply Infrastructure

```bash
make apply
```

This will:
- Create the Hetzner VM
- Attach the persistent volume
- Generate Ansible inventory file

### 4. Deploy Peekaping

```bash
make deploy-peekaping
```

This runs the Ansible playbook which:
- Installs Docker and dependencies
- Configures firewall (UFW)
- Sets up fail2ban
- Mounts the Hetzner volume
- Deploys Peekaping via Docker Compose
- Configures Nginx reverse proxy
- Obtains SSL certificate (Let's Encrypt)

### 5. Access Peekaping

Once deployed, access your instance at:
```
https://peekaping.ainsley.dev
```

## Outputs

| Output | Description |
|--------|-------------|
| `server_id` | Hetzner server ID |
| `ip_address` | Public IP address |
| `ssh_private_key` | SSH private key (sensitive) |
| `ssh_public_key` | SSH public key |
| `volume_id` | Hetzner volume ID |
| `domain` | Configured domain |
| `server_user` | SSH username |

### Export SSH Key

To SSH into the server:

```bash
make ssh-key-peekaping
ssh -i peekaping-key.pem root@<ip-address>
```

## Maintenance

### Version Management

Peekaping versions are controlled by the `PEEKAPING_VERSION` environment variable.

**Check releases**: https://github.com/0xfurai/peekaping/releases

**Best Practices**:
- ✅ Production: Pin to specific versions (e.g., `v1.2.3`)
- ✅ Development: Use `latest` to stay current
- ✅ Always backup database before upgrades
- ✅ Test new versions locally first

### Upgrading Peekaping

**Method 1: Via Ansible (Recommended)**

```bash
# 1. Backup database first
ssh -i peekaping-key.pem root@<ip-address>
cp /mnt/peekaping/peekaping.db /mnt/peekaping/backup-$(date +%Y%m%d).db

# 2. Update version in ansible/playbooks/peekaping.yaml
peekaping_version: v1.2.3

# 3. Re-run deployment
make deploy-peekaping
```

**Method 2: Manual SSH Update**

```bash
# SSH into the server
ssh -i peekaping-key.pem root@<ip-address>

# Update version in .env
cd /opt/peekaping
sed -i 's/PEEKAPING_VERSION=.*/PEEKAPING_VERSION=v1.2.3/' .env

# Pull and restart
docker compose pull && docker compose up -d

# Clean up old images
docker image prune -f
```

**Rollback**: Change version back to previous in `.env` and restart

### View Logs

```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f api
docker compose logs -f worker
```

### Check Service Status

```bash
docker compose ps
```

### Backup Database

The SQLite database is stored on the Hetzner volume at `/mnt/peekaping/peekaping.db`.

To backup:

```bash
# SSH into server
ssh -i peekaping-key.pem root@<ip-address>

# Create backup
cp /mnt/peekaping/peekaping.db /mnt/peekaping/peekaping.db.backup-$(date +%Y%m%d)

# Or download locally
scp -i peekaping-key.pem root@<ip-address>:/mnt/peekaping/peekaping.db ./peekaping-backup.db
```

## Troubleshooting

### Services Not Starting

Check logs for specific services:

```bash
docker compose logs api
docker compose logs worker
```

### Health Check Failed

Verify API is responding:

```bash
curl http://localhost:8383/api/v1/health
```

### SSL Certificate Issues

Re-run Certbot:

```bash
certbot --nginx -d peekaping.ainsley.dev
```

### Volume Not Mounted

Check if volume is attached:

```bash
lsblk
mount | grep peekaping
```

## Architecture Diagram

```
                                    Internet
                                       |
                                    [HTTPS]
                                       |
                            +----------v----------+
                            |   Nginx (Host)      |
                            |   SSL/TLS           |
                            +----------+----------+
                                       |
                            +----------v----------+
                            |   Gateway Container |
                            |   (Nginx)           |
                            +----------+----------+
                                       |
                    +------------------+------------------+
                    |                                     |
            +-------v--------+                    +-------v--------+
            |   API          |                    |   Web          |
            |   (Port 8034)  |                    |   (SPA)        |
            +-------+--------+                    +----------------+
                    |
        +-----------+------------+
        |           |            |
+-------v---+ +-----v-----+ +----v------+
| Producer  | | Ingester  | | Worker    |
+-----------+ +-----------+ +-----------+
        |           |            |
        +-----------|------------+
                    |
            +-------v--------+
            |   Redis        |
            +----------------+
                    |
            +-------v--------+
            | SQLite DB      |
            | /mnt/peekaping |
            +----------------+
```

## Cost Estimation

- **Server (CX23)**: ~€5.83/month
- **Volume (10GB)**: ~€0.50/month
- **Total**: ~€6.33/month

## Security

- Firewall (UFW) configured to allow only necessary ports
- fail2ban installed for intrusion prevention
- SSL/TLS encryption via Let's Encrypt
- SSH key-based authentication
- Automated security updates

## References

- [Peekaping Documentation](https://docs.peekaping.com/)
- [Hetzner Cloud](https://www.hetzner.com/cloud)
- [WebKit Infrastructure](https://github.com/ainsleydev/webkit)
