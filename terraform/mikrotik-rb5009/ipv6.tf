# Nothing uses IPv6 yet, but link-local addresses exist and it may get turned on later
resource "routeros_ipv6_firewall_filter" "input_drop" {
  chain             = "input"
  action            = "drop"
  in_interface_list = "!LAN"
  comment           = "drop IPv6 to the router not coming from LAN"
}

resource "routeros_ipv6_firewall_filter" "forward_drop" {
  chain   = "forward"
  action  = "drop"
  comment = "drop all forwarded IPv6"
}
