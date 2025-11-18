# Base outputs file
# Service-specific outputs should be defined in their respective modules

output "project_name" {
  description = "Project name"
  value       = var.project_name
}

output "environment" {
  description = "Environment name"
  value       = var.environment
}
