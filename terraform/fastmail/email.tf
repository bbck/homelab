resource "cloudflare_record" "mx_10" {
  zone_id  = var.zone_id
  name     = "@"
  value    = "in1-smtp.messagingengine.com"
  type     = "MX"
  priority = 10
}

resource "cloudflare_record" "mx_20" {
  zone_id  = var.zone_id
  name     = "@"
  value    = "in2-smtp.messagingengine.com"
  type     = "MX"
  priority = 20
}

resource "cloudflare_record" "dkim_1" {
  count   = var.disable_email ? 0 : 1
  zone_id = var.zone_id
  name    = "fm1._domainkey"
  value   = "fm1.${var.domain}.dkim.fmhosted.com"
  type    = "CNAME"
  ttl     = 3600
}

resource "cloudflare_record" "dkim_2" {
  count   = var.disable_email ? 0 : 1
  zone_id = var.zone_id
  name    = "fm2._domainkey"
  value   = "fm2.${var.domain}.dkim.fmhosted.com"
  type    = "CNAME"
}

resource "cloudflare_record" "dkim_3" {
  count   = var.disable_email ? 0 : 1
  zone_id = var.zone_id
  name    = "fm3._domainkey"
  value   = "fm3.${var.domain}.dkim.fmhosted.com"
  type    = "CNAME"
}

resource "cloudflare_record" "spf" {
  count   = var.disable_email ? 0 : 1
  zone_id = var.zone_id
  name    = "@"
  value   = "v=spf1 include:spf.messagingengine.com ~all"
  type    = "TXT"
}

resource "cloudflare_record" "spf_disabled" {
  count   = var.disable_email ? 1 : 0
  zone_id = var.zone_id
  name    = "@"
  value   = "v=spf1 -all"
  type    = "TXT"
}

resource "cloudflare_record" "_dmarc" {
  zone_id = var.zone_id
  name    = "_dmarc"
  value   = "v=DMARC1; p=reject; ${var.dmarc_extra}"
  type    = "TXT"
}
