locals {
  management_address = "192.168.88.3/24"

  # The port is required, even for the defaults
  services = {
    api     = { port = 8728, disabled = true, certificate = null }
    api-ssl = { port = 8729, disabled = false, certificate = "MikroTik" }
    ftp     = { port = 21, disabled = true, certificate = null }
    ssh     = { port = 22, disabled = false, certificate = null }
    telnet  = { port = 23, disabled = true, certificate = null }
    winbox  = { port = 8291, disabled = false, certificate = null }
    www     = { port = 80, disabled = true, certificate = null }
    www-ssl = { port = 443, disabled = false, certificate = "MikroTik" }
  }
}

resource "routeros_ip_address" "management" {
  address   = local.management_address
  interface = routeros_interface_bridge.this.name
}

resource "routeros_ip_route" "default" {
  dst_address = "0.0.0.0/0"
  gateway     = "192.168.88.2"
}

resource "routeros_ip_dns" "this" {
  servers = ["1.1.1.1", "1.0.0.1"]
}

resource "routeros_ip_service" "this" {
  for_each = local.services

  numbers     = each.key
  port        = each.value.port
  disabled    = each.value.disabled
  certificate = each.value.certificate
}

resource "routeros_ip_neighbor_discovery_settings" "this" {
  discover_interface_list = routeros_interface_list.management.name
}

resource "routeros_ip_ssh_server" "this" {
  strong_crypto = true
}
