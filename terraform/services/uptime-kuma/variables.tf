variable "hetzner_token" {
  type        = string
  description = "Hetzner Cloud API token"
  sensitive   = true
}

variable "service_name" {
  type        = string
  description = "Name of the service"
  default     = "uptime-kuma"
}

variable "server_type" {
  type        = string
  description = "Hetzner server type (CX23 = 2 vCPU, 4GB RAM, ~€5.83/month)"
  default     = "cx23"
}

variable "location" {
  type        = string
  description = "Hetzner datacenter location"
  default     = "nbg1" # Nuremberg, Germany
}

variable "volume_size" {
  type        = number
  description = "Size of the data volume in GB"
  default     = 10
}

variable "domain" {
  type        = string
  description = "Domain for the Uptime Kuma instance"
  default     = "status.ainsley.dev"
}

variable "admin_email" {
  type        = string
  description = "Admin email for Let's Encrypt certificates"
  default     = "hello@ainsley.dev"
}

variable "environment" {
  type        = string
  description = "Environment name"
  default     = "production"
}

variable "tags" {
  type        = list(string)
  description = "Tags to apply to resources"
  default     = ["uptime-kuma", "monitoring"]
}
