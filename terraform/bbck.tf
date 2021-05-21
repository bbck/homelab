resource "cloudflare_zone" "bbck_dot_net" {
  zone = "bbck.net"
}

module "bbck_dot_net_fastmail" {
  source = "./fastmail"

  domain = "bbck.net"
  zone_id = cloudflare_zone.bbck_dot_net.id
}

resource "cloudflare_record" "bbck_dot_net_keybase" {
  zone_id = cloudflare_zone.bbck_dot_net.id
  name    = "bbck.net"
  value   = "keybase-site-verification=gjmxs4XmkR3l8rCGzsrP_ovalg66TtGYi48ssCj-QYs"
  type    = "TXT"
}
