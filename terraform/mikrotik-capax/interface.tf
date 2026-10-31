locals {
  bridge = "bridge1"
  trunk  = "ether1"

  ethernet = {
    ether1 = { comment = "trunk - rb5009", poe_out = null, disabled = false }
    ether2 = { comment = "spare", poe_out = "off", disabled = true }
  }
}

resource "routeros_interface_ethernet" "this" {
  for_each = local.ethernet

  factory_name = each.key
  name         = each.key
  comment      = each.value.comment
  disabled     = each.value.disabled
  poe_out      = each.value.poe_out
}

# Keeps the bridge MAC from changing to a wifi interface's after a reboot
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

# bridge1 itself only gets the untagged VLAN 1, not the wifi VLANs
resource "routeros_interface_list" "management" {
  name = "management"
}

resource "routeros_interface_list_member" "management" {
  list      = routeros_interface_list.management.name
  interface = routeros_interface_bridge.this.name
}

# The wifi interfaces tag client traffic with their datapath's VLAN
resource "routeros_interface_bridge_vlan" "trusted" {
  bridge   = routeros_interface_bridge.this.name
  comment  = "trusted"
  vlan_ids = [local.networks.trusted.vlan]
  tagged   = concat([local.trunk], values(routeros_wifi.trusted)[*].name)
}

resource "routeros_interface_bridge_vlan" "untrusted" {
  bridge   = routeros_interface_bridge.this.name
  comment  = "untrusted"
  vlan_ids = [local.networks.untrusted.vlan]
  tagged   = concat([local.trunk], values(routeros_wifi.untrusted)[*].name)
}
