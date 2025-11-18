# ainsley.dev Platform

Infrastructure as Code for platform services (monitoring, observability, etc.) using Terraform and
Ansible.

## Overview

This repository manages infrastructure for:

- **Uptime Kuma**: Monitoring and status page service at `uptime.ainsley.dev`
- **Backups**: Terraform backups from Backblaze to Google Drive.

## Architecture

- **Infrastructure**: Terraform with Hetzner Cloud
- **Configuration**: Ansible (references roles from [WebKit](https://github.com/ainsleydev/webkit))
- **Deployment**: Docker Compose on VMs
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

## CI/CD Automation

This repository uses automated Terraform workflows for infrastructure changes:

### Workflow Overview

1. **Pull Request** - Terraform plan runs automatically
   - Shows what infrastructure changes will be made
   - Posts plan output as PR comment
   - Detects destructive changes (deletions) and warns
   - Validates Terraform syntax and security (tfsec, Checkov)
   - Saves plan artifact for exact apply on merge

2. **Merge to Main** - Terraform apply runs with approval gate
   - Downloads saved plan from PR (ensures plan-apply match)
   - Requires approval on `production` environment before applying
   - Backs up state before making changes
   - Posts results back to merged PR and commit
   - Only runs if Terraform files changed

### Reusable Workflows

The repository includes reusable workflow helpers:

- **`.github/workflows/helper-plan.yaml`** - Reusable plan workflow
  - Runs terraform plan
  - Posts formatted results to PR
  - Uploads plan artifact
  - Detects destructive changes

- **`.github/workflows/helper-apply.yaml`** - Reusable apply workflow
  - Downloads plan artifact from PR
  - Backs up state before apply
  - Applies infrastructure changes
  - Requires GitHub environment approval

### Secrets Configuration

Workflows use GitHub organization secrets (already configured):

- `ORG_HETZNER_TOKEN` - Hetzner Cloud API token
- `ORG_BACK_BLAZE_KEY_ID` - Backblaze B2 access key for state backend
- `ORG_BACK_BLAZE_APPLICATION_KEY` - Backblaze B2 secret key

### GitHub Environment Setup

The `production` environment must be configured with:

1. Go to **Settings → Environments → New environment**
2. Name: `production`
3. Add protection rules:
   - ✅ Required reviewers (select yourself)
   - ✅ Deployment branches: `main` only
   - Optional: Wait timer (0-30 minutes)

### Making Infrastructure Changes

#### Automated (Recommended)

```bash
# 1. Create a feature branch
git checkout -b feat/add-new-service

# 2. Make your Terraform changes
vim terraform/services/new-service/main.tf

# 3. Push and create PR
git push origin feat/add-new-service
gh pr create --title "Add new service"

# 4. Review plan output in PR comment
# 5. Get PR approval, then merge
# 6. Approve the deploy in GitHub Actions (production environment)
# 7. Changes applied automatically!
```

#### Manual (Emergency/Testing)

```bash
# Plan deployment
make plan

# Apply (creates VM, volume, firewall)
make apply

# Get access details
make output
```

### Emergency Procedures

If the automated workflow fails:

1. **Check the workflow logs**: Actions tab → Failed workflow → View logs
2. **Manual apply via workflow_dispatch**: Actions → Terraform Apply → Run workflow
3. **Local manual apply**: Use `make apply` with local credentials
4. **State recovery**: Download backup from workflow artifacts (retained 90 days)

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
