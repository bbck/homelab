resource "cloudflare_dns_record" "keybase" {
  zone_id = cloudflare_zone.this["bbck.net"].id
  name    = "bbck.net"
  type    = "TXT"
  ttl     = 1
  content = "\"keybase-site-verification=gjmxs4XmkR3l8rCGzsrP_ovalg66TtGYi48ssCj-QYs\""
}

resource "cloudflare_dns_record" "bluesky" {
  zone_id = cloudflare_zone.this["bbck.net"].id
  name    = "_atproto.bbck.net"
  type    = "TXT"
  ttl     = 1
  content = "\"did=did:plc:qwehyo6hr7pkrfreigz7ebsy\""
}
