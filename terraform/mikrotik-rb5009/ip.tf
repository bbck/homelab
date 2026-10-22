# vlan40 (homelab) is self-contained: it can only reach the internet, and only
# vlan10 (trusted) and port forwards can reach into it. The RouterOS default
# rules stay unmanaged. These are appended after them, with each accept placed
# before the drop it is an exception to.

# Traffic from vlan40 to the router itself. ICMP is already accepted by the
# default rules.

resource "routeros_ip_firewall_filter" "homelab_input_drop" {
  chain        = "input"
  action       = "drop"
  in_interface = "vlan40"
  comment      = "homelab: drop everything else to the router"
}

resource "routeros_ip_firewall_filter" "homelab_input_dhcp" {
  chain        = "input"
  action       = "accept"
  in_interface = "vlan40"
  protocol     = "udp"
  dst_port     = "67"
  comment      = "homelab: DHCP"
  place_before = routeros_ip_firewall_filter.homelab_input_drop.id
}

resource "routeros_ip_firewall_filter" "homelab_input_bgp" {
  chain        = "input"
  action       = "accept"
  in_interface = "vlan40"
  protocol     = "tcp"
  dst_port     = "179"
  comment      = "homelab: BGP from the Kubernetes nodes"
  place_before = routeros_ip_firewall_filter.homelab_input_drop.id
}

resource "routeros_ip_firewall_filter" "homelab_input_api" {
  chain        = "input"
  action       = "accept"
  in_interface = "vlan40"
  dst_address  = "192.168.88.0/24"
  protocol     = "tcp"
  dst_port     = "8729"
  comment      = "homelab: RouterOS API for tofu-controller and mktxp"
  place_before = routeros_ip_firewall_filter.homelab_input_drop.id
}

# Traffic into vlan40

resource "routeros_ip_firewall_filter" "homelab_ingress_drop" {
  chain         = "forward"
  action        = "drop"
  in_interface  = "!vlan40"
  out_interface = "vlan40"
  comment       = "homelab: drop everything else into vlan40"
}

resource "routeros_ip_firewall_filter" "homelab_ingress_trusted" {
  chain         = "forward"
  action        = "accept"
  in_interface  = "vlan10"
  out_interface = "vlan40"
  comment       = "homelab: allow from trusted"
  place_before  = routeros_ip_firewall_filter.homelab_ingress_drop.id
}

resource "routeros_ip_firewall_filter" "homelab_ingress_port_forwards" {
  chain                = "forward"
  action               = "accept"
  connection_nat_state = "dstnat"
  out_interface        = "vlan40"
  comment              = "homelab: allow port forwards"
  place_before         = routeros_ip_firewall_filter.homelab_ingress_drop.id
}

resource "routeros_ip_firewall_nat" "plex" {
  chain             = "dstnat"
  action            = "dst-nat"
  in_interface_list = "WAN"
  protocol          = "tcp"
  dst_port          = "32400"
  to_addresses      = "192.168.40.130"
  to_ports          = "32400"
  comment           = "homelab: plex remote access"
}

# Traffic out of vlan40

resource "routeros_ip_firewall_filter" "homelab_egress_drop" {
  chain         = "forward"
  action        = "drop"
  in_interface  = "vlan40"
  out_interface = "!vlan40"
  comment       = "homelab: drop everything else out of vlan40"
}

resource "routeros_ip_firewall_filter" "homelab_egress_internet" {
  chain              = "forward"
  action             = "accept"
  in_interface       = "vlan40"
  out_interface_list = "WAN"
  comment            = "homelab: allow internet"
  place_before       = routeros_ip_firewall_filter.homelab_egress_drop.id
}

resource "routeros_ip_firewall_filter" "homelab_egress_switch_api" {
  chain        = "forward"
  action       = "accept"
  in_interface = "vlan40"
  dst_address  = "192.168.88.0/24"
  protocol     = "tcp"
  dst_port     = "8729"
  comment      = "homelab: RouterOS API on the cAP ax and CRS310 for mktxp"
  place_before = routeros_ip_firewall_filter.homelab_egress_drop.id
}

# vlan20 (untrusted) can only reach the internet. It isn't in the LAN interface
# list, so the default rules already drop its traffic to the router.

resource "routeros_ip_address" "untrusted" {
  address   = "192.168.20.2/24"
  interface = routeros_interface_vlan.untrusted.name
}

resource "routeros_ip_pool" "untrusted" {
  name   = routeros_interface_vlan.untrusted.name
  ranges = ["192.168.20.128-192.168.20.254"]
}

resource "routeros_ip_dhcp_server" "untrusted" {
  name                      = routeros_interface_vlan.untrusted.name
  interface                 = routeros_interface_vlan.untrusted.name
  address_pool              = routeros_ip_pool.untrusted.name
  lease_time                = "12h"
  dynamic_lease_identifiers = "client-mac,client-id"
}

resource "routeros_ip_dhcp_server_network" "untrusted" {
  address    = "192.168.20.0/24"
  gateway    = "192.168.20.2"
  dns_server = ["1.1.1.2", "9.9.9.9"]
}

# DHCP has to go before the default drop, which isn't managed here
data "routeros_ip_firewall" "defconf_input_drop" {
  rules {
    filter = {
      chain   = "input"
      comment = "defconf: drop all not coming from LAN"
    }
  }
}

resource "routeros_ip_firewall_filter" "untrusted_input_dhcp" {
  chain        = "input"
  action       = "accept"
  in_interface = routeros_interface_vlan.untrusted.name
  protocol     = "udp"
  dst_port     = "67"
  comment      = "untrusted: DHCP"
  place_before = data.routeros_ip_firewall.defconf_input_drop.rules[0].id
}

resource "routeros_ip_firewall_filter" "untrusted_egress_drop" {
  chain         = "forward"
  action        = "drop"
  in_interface  = routeros_interface_vlan.untrusted.name
  out_interface = "!${routeros_interface_vlan.untrusted.name}"
  comment       = "untrusted: drop everything else out of vlan20"
}

resource "routeros_ip_firewall_filter" "untrusted_egress_internet" {
  chain              = "forward"
  action             = "accept"
  in_interface       = routeros_interface_vlan.untrusted.name
  out_interface_list = "WAN"
  comment            = "untrusted: allow internet"
  place_before       = routeros_ip_firewall_filter.untrusted_egress_drop.id
}
