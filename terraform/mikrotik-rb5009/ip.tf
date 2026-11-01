locals {
  # in and out are the interface lists from interface.tf, one per network
  firewall_input = [
    { action = "accept", connection_state = "established,related,untracked", comment = "established" },
    { action = "drop", connection_state = "invalid", comment = "invalid" },
    { action = "accept", protocol = "icmp", comment = "ICMP" },
    { action = "accept", in = "management", comment = "management: anything" },
    { action = "accept", in = "trusted", comment = "trusted: anything" },
    { action = "accept", in = "homelab", protocol = "tcp", dst_port = "179", comment = "homelab: BGP from the Kubernetes nodes" },
    { action = "accept", in = "homelab", protocol = "tcp", dst_port = "8729", dst_address = "192.168.88.2", comment = "homelab: RouterOS API for tofu-controller and mktxp" },
    { action = "accept", in = "homelab", protocol = "udp", dst_port = "67", comment = "homelab: DHCP" },
    { action = "accept", in = "untrusted", protocol = "udp", dst_port = "67", comment = "untrusted: DHCP" },
    { action = "drop", comment = "everything else" },
  ]

  firewall_forward = [
    { action = "fasttrack-connection", connection_state = "established,related", comment = "fasttrack" },
    { action = "accept", connection_state = "established,related,untracked", comment = "established" },
    { action = "drop", connection_state = "invalid", comment = "invalid" },
    { action = "accept", in = "wan", out = "homelab", connection_nat_state = "dstnat", comment = "wan: port forwards" },
    { action = "accept", in = "trusted", comment = "trusted: anywhere" },
    { action = "accept", in = "management", out = "wan", comment = "management: internet" },
    { action = "accept", in = "management", out = "homelab", protocol = "udp", dst_port = "514", dst_address = "192.168.40.131", comment = "management: syslog to Loki" },
    { action = "accept", in = "homelab", out = "wan", comment = "homelab: internet" },
    { action = "accept", in = "homelab", out = "management", protocol = "tcp", dst_port = "8729", comment = "homelab: RouterOS API for tofu-controller and mktxp" },
    { action = "accept", in = "untrusted", out = "wan", comment = "untrusted: internet" },
    { action = "drop", comment = "everything else" },
  ]

  firewall_nat = [
    { chain = "srcnat", action = "masquerade", out = "wan", comment = "masquerade" },
    { chain = "dstnat", action = "dst-nat", in = "wan", protocol = "tcp", dst_port = "32400", to_addresses = "192.168.40.130", to_ports = "32400", comment = "plex remote access" },
  ]

  firewall_filter = [
    for rule in concat(
      [for rule in local.firewall_input : merge(rule, { chain = "input" })],
      [for rule in local.firewall_forward : merge(rule, { chain = "forward" })],
    ) : merge(rule, { key = "${rule.chain}/${rule.comment}" })
  ]

  networks = {
    management = { address = "192.168.88.2/24", pool = "192.168.88.128-192.168.88.254" }
    trusted    = { address = "192.168.10.2/24", pool = "192.168.10.128-192.168.10.254" }
    untrusted  = { address = "192.168.20.2/24", pool = "192.168.20.128-192.168.20.254" }
    homelab    = { address = "192.168.40.2/24", pool = "192.168.40.192-192.168.40.254" }
  }

  homelab_leases = {
    rk1-1    = { address = "192.168.40.41", mac_address = "7A:CC:3E:AF:E6:B1" }
    rk1-2    = { address = "192.168.40.42", mac_address = "A2:3A:9A:46:3A:A2" }
    rk1-3    = { address = "192.168.40.43", mac_address = "BA:F5:04:62:97:60" }
    rk1-4    = { address = "192.168.40.44", mac_address = "D2:F1:42:07:A5:EA" }
    eq12     = { address = "192.168.40.45", mac_address = "E8:FF:1E:D2:47:C5" }
    eq14     = { address = "192.168.40.46", mac_address = "E8:FF:1E:DB:93:FF" }
    cm3588   = { address = "192.168.40.47", mac_address = "46:69:6E:7E:7A:1E" }
    turingpi = { address = "192.168.40.48", mac_address = "02:00:45:8F:1D:7C" }
  }

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

resource "routeros_ip_firewall_filter" "this" {
  for_each = { for rule in local.firewall_filter : rule.key => rule if rule.action != "drop" }

  chain                = each.value.chain
  action               = each.value.action
  comment              = each.value.comment
  in_interface_list    = lookup(each.value, "in", null)
  out_interface_list   = lookup(each.value, "out", null)
  protocol             = lookup(each.value, "protocol", null)
  dst_address          = lookup(each.value, "dst_address", null)
  dst_port             = lookup(each.value, "dst_port", null)
  connection_state     = lookup(each.value, "connection_state", null)
  connection_nat_state = lookup(each.value, "connection_nat_state", null)

  depends_on = [routeros_interface_list_member.this]
}

# New rules are appended, so the drops go in after the accepts. Otherwise the
# first apply could drop its own API connection.
resource "routeros_ip_firewall_filter" "drop" {
  for_each = { for rule in local.firewall_filter : rule.key => rule if rule.action == "drop" }

  chain                = each.value.chain
  action               = each.value.action
  comment              = each.value.comment
  in_interface_list    = lookup(each.value, "in", null)
  out_interface_list   = lookup(each.value, "out", null)
  protocol             = lookup(each.value, "protocol", null)
  dst_address          = lookup(each.value, "dst_address", null)
  dst_port             = lookup(each.value, "dst_port", null)
  connection_state     = lookup(each.value, "connection_state", null)
  connection_nat_state = lookup(each.value, "connection_nat_state", null)

  depends_on = [routeros_ip_firewall_filter.this]
}

resource "routeros_move_items" "firewall_filter" {
  resource_path = "/ip/firewall/filter"
  sequence = [
    for rule in local.firewall_filter :
    merge(routeros_ip_firewall_filter.this, routeros_ip_firewall_filter.drop)[rule.key].id
  ]
}

resource "routeros_ip_firewall_nat" "this" {
  for_each = { for rule in local.firewall_nat : "${rule.chain}/${rule.comment}" => rule }

  chain              = each.value.chain
  action             = each.value.action
  comment            = each.value.comment
  in_interface_list  = lookup(each.value, "in", null)
  out_interface_list = lookup(each.value, "out", null)
  protocol           = lookup(each.value, "protocol", null)
  dst_port           = lookup(each.value, "dst_port", null)
  to_addresses       = lookup(each.value, "to_addresses", null)
  to_ports           = lookup(each.value, "to_ports", null)

  depends_on = [routeros_interface_list_member.this]
}

# The WAN only comes up once the firewall is in place
resource "routeros_ip_dhcp_client" "wan" {
  interface    = local.wan
  use_peer_dns = false
  use_peer_ntp = false

  depends_on = [routeros_move_items.firewall_filter, routeros_ip_firewall_nat.this]
}

resource "routeros_ip_address" "this" {
  for_each = local.networks

  address   = each.value.address
  interface = local.interface_lists[each.key]
}

resource "routeros_ip_pool" "this" {
  for_each = local.networks

  name   = each.key
  ranges = [each.value.pool]
}

resource "routeros_ip_dhcp_server" "this" {
  for_each = local.networks

  name                      = each.key
  interface                 = routeros_ip_address.this[each.key].interface
  address_pool              = routeros_ip_pool.this[each.key].name
  lease_time                = "12h"
  dynamic_lease_identifiers = "client-mac,client-id"
}

resource "routeros_ip_dhcp_server_network" "this" {
  for_each = local.networks

  address    = cidrsubnet(each.value.address, 0, 0)
  gateway    = split("/", each.value.address)[0]
  dns_server = ["1.1.1.2", "9.9.9.9"]
}

resource "routeros_ip_dhcp_server_lease" "homelab" {
  for_each = local.homelab_leases

  server      = routeros_ip_dhcp_server.this["homelab"].name
  address     = each.value.address
  mac_address = each.value.mac_address
  comment     = each.key
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
  discover_interface_list = routeros_interface_list.this["management"].name
}

resource "routeros_ip_ssh_server" "this" {
  strong_crypto = true
}
