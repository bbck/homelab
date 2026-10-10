locals {
  ethernet = {
    ether1 = { comment = "trunk - rb5009", disabled = false }
    ether2 = { comment = "spare", disabled = true }
  }
}

resource "routeros_interface_ethernet" "this" {
  for_each = local.ethernet

  factory_name = each.key
  name         = each.key
  comment      = each.value.comment
  disabled     = each.value.disabled
}
