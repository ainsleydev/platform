# Ainsley Dev Platform

Infrastructure as Code for platform services (monitoring, observability, etc.) using Terraform and Ansible.

## Overview

This repository manages infrastructure for:
- **Uptime Kuma**: Monitoring and status page service at `status.ainsley.dev`
- Future platform services...

## Architecture

- **Infrastructure**: Terraform with Hetzner Cloud
- **Configuration**: Ansible (references roles from [WebKit](https://github.com/ainsleydev/webkit))
- **Deployment**: Docker Compose on VMs
- **Provisioning**: Cloud-init
- **State**: Backblaze B2 remote backend

## Directory Structure

```
platform/
├── terraform/
│   ├── base/                     # Base Terraform configuration
│   │   ├── providers.tf          # Hetzner provider
│   │   ├── backend.tf            # B2 remote state
│   │   ├── variables.tf          # Global variables
│   │   ├── outputs.tf            # Global outputs
│   │   └── main.tf               # Module imports
│   └── services/
│       └── uptime-kuma/          # Uptime Kuma service
│           ├── main.tf           # VM + firewall
│           ├── volume.tf         # 10GB persistent volume
│           ├── cloud-init.yaml   # VM provisioning
│           ├── variables.tf
│           └── outputs.tf
├── ansible/
│   ├── playbooks/
│   │   └── uptime-kuma.yaml      # Uptime Kuma deployment
│   └── ansible.cfg               # References WebKit roles
├── docker/
│   └── uptime-kuma/
│       ├── docker-compose.yml    # Works for local + VM
│       ├── .env.example
│       └── README.md
└── .github/workflows/
    ├── terraform-plan.yml        # PR checks
    └── terraform-apply.yml       # Deploy to production
```

## Prerequisites

1. **Hetzner Cloud Account**
   - Create account at: https://www.hetzner.com/cloud
   - Generate API token: Console -> Project -> Security -> API Tokens

2. **Backblaze B2 Account** (for Terraform state)
   - Create account at: https://www.backblaze.com/b2/
   - Create bucket: `ainsley-dev-terraform`
   - Generate application key

3. **Local Tools**
   ```bash
   brew install terraform tflint ansible docker
   ```

## Setup

### 1. Configure Terraform Variables

```bash
# Copy example tfvars
cp terraform.tfvars.example terraform.tfvars

# Edit with your Hetzner token and other values
vim terraform.tfvars
```

### 2. Initialize Terraform

```bash
# Initialize with B2 backend
make init

# Or manually:
# cd terraform/base
# terraform init \
#   -backend-config="access_key=${BACK_BLAZE_KEY_ID}" \
#   -backend-config="secret_key=${BACK_BLAZE_APPLICATION_KEY}"
```

## Makefile Commands

Common Terraform operations are available via Make targets:

```bash
make help        # Show all available commands
make setup       # Install required tools (terraform, tflint, ansible)
make fmt         # Format Terraform files
make lint        # Lint Terraform files
make init        # Initialize Terraform with B2 backend
make plan        # Run Terraform plan
make apply       # Apply Terraform changes
make destroy     # Destroy Terraform infrastructure
make output      # Show Terraform outputs
make ssh-key     # Save SSH private key to uptime-kuma-key.pem
```

## Usage

### Deploy Uptime Kuma

```bash
# Plan deployment
make plan

# Apply (creates VM, volume, firewall)
make apply

# Get access details
make output
```

### Configure DNS

After deployment, configure DNS:
```
Type: A
Name: status (or @ for root domain)
Value: <SERVER_IP from terraform output>
TTL: 300
```

### Access Server

```bash
# Save SSH key using Makefile
make ssh-key

# SSH into server
ssh -i uptime-kuma-key.pem root@<SERVER_IP>

# Monitor cloud-init progress
tail -f /var/log/cloud-init-output.log
```

### Local Development

```bash
cd docker/uptime-kuma

# Copy environment file
cp .env.example .env

# Start Uptime Kuma locally
docker-compose up -d

# Access at http://localhost:3001

# View logs
docker-compose logs -f

# Stop
docker-compose down
```

## Services

### Uptime Kuma

**Production**: https://status.ainsley.dev
**Local**: http://localhost:3001

- **Server**: Hetzner CX23 (2 vCPU, 4GB RAM) in Nuremberg
- **Storage**: 10GB Hetzner volume at `/mnt/uptime-kuma`
- **Reverse Proxy**: Nginx with Let's Encrypt SSL
- **Firewall**: UFW (SSH, HTTP, HTTPS only)
- **Security**: Fail2ban intrusion prevention

## Ansible Roles

This project references Ansible roles from the [WebKit](https://github.com/ainsleydev/webkit) repository:

- `docker` - Docker installation
- `nginx` - Nginx web server with SSL
- `certbot` - Let's Encrypt SSL certificates
- `ufw` - Firewall configuration
- `fail2ban` - Intrusion prevention

See `ansible/ansible.cfg` for role path configuration.

## Terraform Modules

This project adapts patterns from [WebKit's Terraform modules](https://github.com/ainsleydev/webkit/tree/main/platform/terraform):

- Hetzner server provisioning
- Firewall rules
- SSH key generation
- Cloud-init integration

## CI/CD

### Terraform Plan (on PR)
- Validates Terraform syntax
- Runs `terraform plan`
- Posts plan output as PR comment

### Terraform Apply (on merge to main)
- Applies infrastructure changes
- Updates remote state in B2

## Maintenance

### Update Uptime Kuma

SSH into server and run:
```bash
cd /opt/uptime-kuma
docker-compose pull
docker-compose up -d
```

### Backup

Terraform state is automatically backed up:
- **Primary**: Backblaze B2 (`ainsley-dev-terraform` bucket)
- **Backup**: Google Drive (via GitHub Actions workflow)
- **Schedule**: Daily at 4 AM UTC

### Destroy Infrastructure

```bash
# Destroy all resources
make destroy
```

**Warning**: This will permanently delete the VM and all data!

## Troubleshooting

### Cloud-init logs

```bash
ssh -i uptime-kuma-key.pem root@<SERVER_IP>
tail -f /var/log/cloud-init-output.log
cat /var/log/cloud-init.log
```

### Uptime Kuma not starting

```bash
cd /opt/uptime-kuma
docker-compose logs -f
docker-compose ps
```

### SSL certificate issues

```bash
# Check Certbot logs
journalctl -u certbot

# Manually run Certbot
certbot certonly --nginx -d status.ainsley.dev
```

### Ansible playbook failed

```bash
# Re-run Ansible playbook manually
cd /tmp
ANSIBLE_ROLES_PATH=/opt/webkit/platform/ansible/roles \
  ansible-playbook -i ansible-inventory.ini uptime-kuma-playbook.yaml
```

## Contributing

1. Create a feature branch
2. Make changes
3. Run `terraform fmt -recursive` and `make lint`
4. Submit PR
5. Merge after approval + successful plan

## License

MIT License - see LICENSE file

## Support

For issues or questions:
- GitHub Issues: https://github.com/ainsleydev/platform/issues
- Email: hello@ainsley.dev
