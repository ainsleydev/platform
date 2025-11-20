# Main Terraform configuration for ainsley.dev Platform
# This file imports and configures service modules

module "peekaping" {
  source = "../services/peekaping"

  hetzner_token = var.hetzner_token
  domain        = var.peekaping_domain
  admin_email   = var.admin_email
  environment   = var.environment
}
