# Uptime Kuma Service Module
# This module creates a Hetzner VM for Uptime Kuma monitoring service
# Adapted from WebKit's Hetzner server module pattern but with custom cloud-init

terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

provider "hcloud" {
  token = var.hetzner_token
}

# Generate SSH key for server access
resource "tls_private_key" "this" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "hcloud_ssh_key" "this" {
  name       = "${var.service_name}-key"
  public_key = tls_private_key.this.public_key_openssh
}

# Hetzner Server for Uptime Kuma
# Pattern adapted from WebKit's server module
resource "hcloud_server" "this" {
  name        = var.service_name
  image       = "ubuntu-24.04"
  server_type = var.server_type
  location    = var.location
  labels      = { for tag in var.tags : tag => "true" }

  ssh_keys = [hcloud_ssh_key.this.id]

  lifecycle {
    create_before_destroy = true
  }

  # Custom cloud-init for Uptime Kuma deployment
  user_data = templatefile("${path.module}/cloud-init.yaml", {
    domain      = var.domain
    admin_email = var.admin_email
  })
}

# Firewall configuration (adapted from WebKit pattern)
resource "hcloud_firewall" "this" {
  name = "${var.service_name}-firewall"

  # SSH access
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "22"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  # HTTP access
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "80"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  # HTTPS access
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "443"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  # ICMP (ping)
  rule {
    direction = "in"
    protocol  = "icmp"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  # Outbound TCP
  rule {
    direction = "out"
    protocol  = "tcp"
    port      = "any"
    destination_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  # Outbound UDP
  rule {
    direction = "out"
    protocol  = "udp"
    port      = "any"
    destination_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  # Outbound ICMP
  rule {
    direction = "out"
    protocol  = "icmp"
    destination_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
}

# Attach firewall to server
resource "hcloud_firewall_attachment" "this" {
  firewall_id = hcloud_firewall.this.id
  server_ids  = [hcloud_server.this.id]
}
