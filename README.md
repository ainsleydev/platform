# ainsley.dev Platform

Infrastructure as Code for platform services (monitoring, observability, etc.) using Terraform and
Ansible.

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

## Ansible Roles

This project references Ansible roles from the [WebKit](https://github.com/ainsleydev/webkit)
repository:

- `docker` - Docker installation
- `nginx` - Nginx web server with SSL
- `certbot` - Let's Encrypt SSL certificates
- `ufw` - Firewall configuration
- `fail2ban` - Intrusion prevention

See `ansible/ansible.cfg` for role path configuration.

## Terraform Modules

This project adapts patterns
from [WebKit's Terraform modules](https://github.com/ainsleydev/webkit/tree/main/platform/terraform):

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
