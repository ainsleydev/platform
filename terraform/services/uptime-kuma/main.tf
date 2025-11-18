# Uptime Kuma Service Module
# This module creates a Hetzner VM for Uptime Kuma monitoring service using WebKit's server module

terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.0"
    }
  }
}

provider "hcloud" {
  token = var.hetzner_token
}

# Use WebKit's Hetzner server module
# This creates the VM, SSH keys, firewall, and installs Ansible via cloud-init
module "server" {
  source = "github.com/ainsleydev/webkit//platform/terraform/providers/hetzner/server?ref=main"

  name        = var.service_name
  server_type = var.server_type
  location    = var.location
  tags        = var.tags
}

# Hetzner Volume for persistent Uptime Kuma data
# Uses WebKit's volume module from GitHub
module "volume" {
  source = "github.com/ainsleydev/webkit//platform/terraform/providers/hetzner/volume?ref=main"

  name      = "${var.service_name}-data"
  size      = var.volume_size
  location  = var.location
  server_id = module.server.id
  format    = "ext4"
  automount = true
  tags      = concat(var.tags, [var.environment])
}

