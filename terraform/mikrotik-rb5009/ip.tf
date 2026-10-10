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
