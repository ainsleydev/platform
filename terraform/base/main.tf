# Main Terraform configuration for Ainsley Dev Platform
# This file imports and configures service modules

# Import Uptime Kuma service module
module "uptime_kuma" {
  source = "../services/uptime-kuma"

  hetzner_token = var.hetzner_token
  admin_email   = var.admin_email
  environment   = var.environment
}
