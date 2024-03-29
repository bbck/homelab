resource "cloudflare_record" "mx_10" {
  zone_id  = var.zone_id
  name     = var.domain
  value    = "in1-smtp.messagingengine.com"
  type     = "MX"
  priority = 10
}

resource "cloudflare_record" "mx_20" {
  zone_id  = var.zone_id
  name     = var.domain
  value    = "in2-smtp.messagingengine.com"
  type     = "MX"
  priority = 20
}

resource "cloudflare_record" "dkim_1" {
  zone_id = var.zone_id
  name    = "fm1._domainkey"
  value   = "fm1.${var.domain}.dkim.fmhosted.com"
  type    = "CNAME"
  ttl     = 3600
}

resource "cloudflare_record" "dkim_2" {
  zone_id = var.zone_id
  name    = "fm2._domainkey"
  value   = "fm2.${var.domain}.dkim.fmhosted.com"
  type    = "CNAME"
}

resource "cloudflare_record" "dkim_3" {
  zone_id = var.zone_id
  name    = "fm3._domainkey"
  value   = "fm3.${var.domain}.dkim.fmhosted.com"
  type    = "CNAME"
}

resource "cloudflare_record" "spf" {
  zone_id = var.zone_id
  name    = var.domain
  value   = "v=spf1 include:spf.messagingengine.com ~all"
  type    = "TXT"
}

resource "cloudflare_record" "_dmarc" {
  zone_id = var.zone_id
  name    = "_dmarc"
  value   = "v=DMARC1; p=reject;%{if var.dmarc_extra != ""} ${var.dmarc_extra}%{endif}"
  type    = "TXT"
}
