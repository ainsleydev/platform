variable "hetzner_token" {
  type        = string
  description = "Hetzner Cloud API token"
  sensitive   = true
}

variable "project_name" {
  type        = string
  description = "Name of the project (used for resource naming)"
  default     = "ainsley-dev-platform"
}

variable "environment" {
  type        = string
  description = "Environment name"
  default     = "production"

  validation {
    condition     = contains(["development", "staging", "production"], var.environment)
    error_message = "Environment must be one of: development, staging, production"
  }
}

variable "admin_email" {
  type        = string
  description = "Admin email for Let's Encrypt certificates"
  default     = "hello@ainsley.dev"
}
