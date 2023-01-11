resource "cloudflare_zone" "bbck_dot_net" {
  zone = "bbck.net"
}

module "bbck_dot_net_fastmail" {
  source = "./fastmail"

  domain      = "bbck.net"
  zone_id     = cloudflare_zone.bbck_dot_net.id
  dmarc_extra = "rua=mailto:478fff8e@in.mailhardener.com"
}

resource "cloudflare_record" "smtp_tls_reporting" {
  zone_id = cloudflare_zone.bbck_dot_net.id
  name    = "_smtp._tls"
  value   = "v=TLSRPTv1; rua=mailto:478fff8e@in.mailhardener.com"
  type    = "TXT"
  ttl     = 3600
}

resource "cloudflare_record" "bbck_dot_net_keybase" {
  zone_id = cloudflare_zone.bbck_dot_net.id
  name    = "bbck.net"
  value   = "keybase-site-verification=gjmxs4XmkR3l8rCGzsrP_ovalg66TtGYi48ssCj-QYs"
  type    = "TXT"
}
