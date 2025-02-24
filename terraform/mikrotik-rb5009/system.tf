resource "routeros_system_identity" "this" {
  name = "RB5009"
}

resource "routeros_system_clock" "this" {
  time_zone_name       = "America/Los_Angeles"
  time_zone_autodetect = false
}

resource "routeros_system_ntp_client" "this" {
  enabled = true
  mode    = "unicast"
  servers = ["time.cloudflare.com"]
}
