resource "routeros_system_identity" "this" {
  name = "rb5009"
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

resource "routeros_system_logging_action" "loki" {
  name               = "loki"
  target             = "remote"
  remote             = "192.168.40.131"
  remote_port        = 514
  remote_protocol    = "udp"
  remote_log_format  = "syslog"
  syslog_time_format = "bsd-syslog"
}

resource "routeros_system_logging" "loki" {
  for_each = {
    info     = ["info"]
    warning  = ["warning"]
    error    = ["error"]
    critical = ["critical", "!error"]
  }

  topics = each.value
  action = routeros_system_logging_action.loki.name
}
