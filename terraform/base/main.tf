# Main Terraform configuration for ainsley.dev Platform
# This file imports and configures service modules

module "uptime_kuma" {
  source = "../services/uptime-kuma"

  hetzner_token = var.hetzner_token
  domain        = var.uptime_kuma_domain
  admin_email   = var.admin_email
  environment   = var.environment
}

module "peekaping" {
  source = "../services/peekaping"

  hetzner_token = var.hetzner_token
  domain        = var.peekaping_domain
  admin_email   = var.admin_email
  environment   = var.environment
}
