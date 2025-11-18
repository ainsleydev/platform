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

  prevent_destroy = var.environment == "production"
}
