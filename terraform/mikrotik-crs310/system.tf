locals {
  user_groups = {
    monitoring = ["read", "api"]
    terraform  = ["read", "write", "policy", "password", "sensitive", "api"]
  }

  users = {
    admin      = { group = "full", item = "routeros-admin" }
    monitoring = { group = "monitoring", item = "routeros-monitoring" }
    terraform  = { group = "terraform", item = "routeros-terraform" }
  }
}

resource "routeros_system_identity" "this" {
  name = "crs310"
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

resource "routeros_system_user_group" "this" {
  for_each = local.user_groups

  name   = each.key
  policy = each.value
}

resource "routeros_system_user" "this" {
  for_each = local.users

  name     = data.onepassword_item.user[each.key].username
  group    = each.value.group
  password = data.onepassword_item.user[each.key].password

  depends_on = [routeros_system_user_group.this]
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
