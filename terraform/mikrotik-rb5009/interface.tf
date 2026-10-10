locals {
  # The SFP+ port has no PoE
  ethernet = {
    ether1       = { comment = "wan", poe_out = "off", disabled = false }
    ether2       = { comment = "trunk - cap ax", poe_out = "auto-on", disabled = false }
    ether3       = { comment = "spare", poe_out = "off", disabled = true }
    ether4       = { comment = "spare", poe_out = "off", disabled = true }
    ether5       = { comment = "spare", poe_out = "off", disabled = true }
    ether6       = { comment = "spare", poe_out = "off", disabled = true }
    ether7       = { comment = "spare", poe_out = "off", disabled = true }
    ether8       = { comment = "spare", poe_out = "off", disabled = true }
    sfp-sfpplus1 = { comment = "trunk - crs310", poe_out = null, disabled = false }
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
