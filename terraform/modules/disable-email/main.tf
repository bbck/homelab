resource "cloudflare_record" "spf" {
  zone_id = var.zone_id
  name    = var.domain
  value   = "v=spf1 -all"
  type    = "TXT"
}
