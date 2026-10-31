locals {
  bridge = "bridge1"
  trunk  = "sfp-sfpplus2"

  ethernet = {
    ether1       = { comment = "lunarian", vlan = 10, disabled = false }
    ether2       = { comment = "appletv", vlan = 10, disabled = false }
    ether3       = { comment = "turingpi - ge0", vlan = 40, disabled = false }
    ether4       = { comment = "turingpi - ge1", vlan = 40, disabled = false }
    ether5       = { comment = "eq12", vlan = 40, disabled = false }
    ether6       = { comment = "eq14", vlan = 40, disabled = false }
    ether7       = { comment = "cm3588", vlan = 40, disabled = false }
    ether8       = { comment = "spare", vlan = 40, disabled = true }
    sfp-sfpplus1 = { comment = "spare", vlan = null, disabled = true }
    sfp-sfpplus2 = { comment = "trunk - rb5009", vlan = null, disabled = false }
  }

  access_ports = { for name, port in local.ethernet : name => port if port.vlan != null }
}

resource "routeros_interface_ethernet" "this" {
  for_each = local.ethernet

  factory_name = each.key
  name         = each.key
  comment      = each.value.comment
  disabled     = each.value.disabled
}

resource "routeros_interface_bridge" "this" {
  name           = local.bridge
  vlan_filtering = true
  auto_mac       = false
  admin_mac      = routeros_interface_ethernet.this[local.trunk].orig_mac_address
}

resource "routeros_interface_bridge_port" "trunk" {
  bridge    = routeros_interface_bridge.this.name
  interface = local.trunk
}

resource "routeros_interface_bridge_port" "port" {
  for_each = local.access_ports

  bridge            = routeros_interface_bridge.this.name
  interface         = each.key
  pvid              = each.value.vlan
  frame_types       = "admit-only-untagged-and-priority-tagged"
  ingress_filtering = true
}

# bridge1 itself only gets the untagged VLAN 1, not the access port VLANs
resource "routeros_interface_list" "management" {
  name = "management"
}

resource "routeros_interface_list_member" "management" {
  list      = routeros_interface_list.management.name
  interface = routeros_interface_bridge.this.name
}

resource "routeros_interface_bridge_vlan" "trusted" {
  bridge   = routeros_interface_bridge.this.name
  comment  = "trusted"
  vlan_ids = ["10"]
  tagged   = [routeros_interface_bridge_port.trunk.interface]
  untagged = [
    for port in routeros_interface_bridge_port.port : port.interface
    if port.pvid == 10
  ]
}

resource "routeros_interface_bridge_vlan" "homelab" {
  bridge   = routeros_interface_bridge.this.name
  comment  = "homelab"
  vlan_ids = ["40"]
  tagged   = [routeros_interface_bridge_port.trunk.interface]
  untagged = [
    for port in routeros_interface_bridge_port.port : port.interface
    if port.pvid == 40
  ]
}
