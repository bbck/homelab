locals {
  bridge = "bridge1"

  # Carries VLAN 10 and 40 tagged to the RB5009. Switch management stays on
  # the untagged VLAN 1.
  trunk = "sfp-sfpplus2"

  # vlan is the untagged VLAN of an access port
  ethernet = {
    ether1       = { comment = "lunarian", vlan = 10, disabled = false }
    ether2       = { comment = "appletv", vlan = 10, disabled = false }
    ether3       = { comment = "turingpi", vlan = 40, disabled = false }
    ether4       = { comment = "turingpi - second nic", vlan = 40, disabled = true }
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

resource "routeros_interface_bridge_port" "port" {
  for_each = local.access_ports

  bridge            = local.bridge
  interface         = each.key
  pvid              = each.value.vlan
  frame_types       = "admit-only-untagged-and-priority-tagged"
  ingress_filtering = true
}

resource "routeros_interface_bridge_vlan" "trusted" {
  bridge   = local.bridge
  comment  = "trusted"
  vlan_ids = ["10"]
  tagged   = [local.trunk]
  untagged = [for name, port in local.access_ports : name if port.vlan == 10]
}

resource "routeros_interface_bridge_vlan" "homelab" {
  bridge   = local.bridge
  comment  = "homelab"
  vlan_ids = ["40"]
  tagged   = [local.trunk]
  untagged = [for name, port in local.access_ports : name if port.vlan == 40]
}
