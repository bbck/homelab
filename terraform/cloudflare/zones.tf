resource "cloudflare_zone" "this" {
  for_each = var.domains

  account = {
    id = local.account_id
  }
  name = each.key
}

resource "cloudflare_zone_dnssec" "this" {
  for_each = var.domains

  zone_id = cloudflare_zone.this[each.key].id
  status  = "active"
}
