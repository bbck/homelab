locals {
  bridge     = "bridge1"
  wan        = "ether1"
  breakglass = "ether8"

  ethernet = {
    ether1       = { comment = "wan", poe_out = "off", disabled = false }
    ether2       = { comment = "trunk - cap ax", poe_out = "auto-on", disabled = false }
    ether3       = { comment = "spare", poe_out = "off", disabled = true }
    ether4       = { comment = "spare", poe_out = "off", disabled = true }
    ether5       = { comment = "spare", poe_out = "off", disabled = true }
    ether6       = { comment = "spare", poe_out = "off", disabled = true }
    ether7       = { comment = "spare", poe_out = "off", disabled = true }
    ether8       = { comment = "breakglass", poe_out = "off", disabled = false }
    sfp-sfpplus1 = { comment = "trunk - crs310", poe_out = null, disabled = false }
  }

  vlans = {
    trusted   = { id = 10, trunks = ["ether2", "sfp-sfpplus1"] }
    untrusted = { id = 20, trunks = ["ether2", "sfp-sfpplus1"] }
    homelab   = { id = 40, trunks = ["sfp-sfpplus1"] }
  }

  # Tagged traffic arrives on the vlan interfaces, so bridge1 only matches the
  # untagged VLAN 1
  interface_lists = merge(
    { wan = local.wan, management = local.bridge },
    { for name, vlan in routeros_interface_vlan.this : name => vlan.name },
  )
}

resource "routeros_interface_ethernet" "this" {
  for_each = local.ethernet

  factory_name = each.key
  name         = each.key
  comment      = each.value.comment
  disabled     = each.value.disabled
  poe_out      = each.value.poe_out
}

resource "routeros_interface_bridge" "this" {
  name           = local.bridge
  vlan_filtering = true
  auto_mac       = false
  admin_mac      = routeros_interface_ethernet.this["ether2"].orig_mac_address
}

resource "routeros_interface_bridge_port" "breakglass" {
  bridge    = routeros_interface_bridge.this.name
  interface = local.breakglass
}

resource "routeros_interface_bridge_port" "trunk" {
  for_each = toset(flatten(values(local.vlans)[*].trunks))

  bridge    = routeros_interface_bridge.this.name
  interface = each.key
}

resource "routeros_interface_vlan" "this" {
  for_each = local.vlans

  name      = "vlan${each.value.id}"
  comment   = each.key
  interface = routeros_interface_bridge.this.name
  vlan_id   = each.value.id
}

resource "routeros_interface_bridge_vlan" "this" {
  for_each = local.vlans

  bridge   = routeros_interface_bridge.this.name
  comment  = each.key
  vlan_ids = [each.value.id]
  tagged = concat(
    [routeros_interface_bridge.this.name],
    [for trunk in each.value.trunks : routeros_interface_bridge_port.trunk[trunk].interface],
  )
}

resource "routeros_interface_list" "this" {
  for_each = local.interface_lists

  name = each.key
}

resource "routeros_interface_list_member" "this" {
  for_each = local.interface_lists

  list      = routeros_interface_list.this[each.key].name
  interface = each.value
}
