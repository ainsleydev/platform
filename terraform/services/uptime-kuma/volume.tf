# Hetzner Volume for persistent Uptime Kuma data
resource "hcloud_volume" "uptime_kuma_data" {
  name     = "${var.service_name}-data"
  size     = var.volume_size
  location = var.location
  format   = "ext4"
  labels = {
    service     = var.service_name
    environment = var.environment
  }
}

# Attach volume to the server
resource "hcloud_volume_attachment" "uptime_kuma_data" {
  volume_id = hcloud_volume.uptime_kuma_data.id
  server_id = module.server.id
  automount = true
}
