terraform {
  # Keep this version in sync with WebKit's terraform version requirement
  required_version = ">= 1.13.0"

  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.0"
    }
  }
}

# Hetzner Cloud Provider
# Token should be provided via HETZNER_TOKEN environment variable
provider "hcloud" {
  token = var.hetzner_token
}
