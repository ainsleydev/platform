output "server_id" {
  description = "The ID of the Hetzner server"
  value       = module.server.id
}

output "ip_address" {
  description = "The public IP address of the server"
  value       = module.server.ip_address
}

output "ssh_private_key" {
  description = "SSH private key for server access"
  value       = module.server.ssh_private_key
  sensitive   = true
}

output "ssh_public_key" {
  description = "SSH public key for server access"
  value       = module.server.ssh_public_key
}

output "volume_id" {
  description = "The ID of the Hetzner volume"
  value       = module.volume.id
}

output "domain" {
  description = "The domain for the Peekaping instance"
  value       = var.domain
}

output "server_user" {
  description = "SSH user for the server"
  value       = module.server.server_user
}
