locals {
  enable_email = {
    for k, v in var.domains : k => v
    if v.email
  }
  disable_email = {
    for k, v in var.domains : k => v
    if !v.email
  }
}

resource "cloudflare_dns_record" "mx_10" {
  for_each = local.enable_email

  zone_id  = cloudflare_zone.this[each.key].id
  name     = "@"
  type     = "MX"
  ttl      = 1
  content  = "in1-smtp.messagingengine.com"
  priority = 10
}

resource "cloudflare_dns_record" "mx_20" {
  for_each = local.enable_email

  zone_id  = cloudflare_zone.this[each.key].id
  name     = "@"
  type     = "MX"
  ttl      = 1
  content  = "in2-smtp.messagingengine.com"
  priority = 20
}

resource "cloudflare_dns_record" "dkim_1" {
  for_each = local.enable_email

  zone_id = cloudflare_zone.this[each.key].id
  name    = "fm1._domainkey"
  type    = "CNAME"
  ttl     = 1
  content = "fm1.${each.key}.dkim.fmhosted.com"
}

resource "cloudflare_dns_record" "dkim_2" {
  for_each = local.enable_email

  zone_id = cloudflare_zone.this[each.key].id
  name    = "fm2._domainkey"
  type    = "CNAME"
  ttl     = 1
  content = "fm2.${each.key}.dkim.fmhosted.com"
}

resource "cloudflare_dns_record" "dkim_3" {
  for_each = local.enable_email

  zone_id = cloudflare_zone.this[each.key].id
  name    = "fm3._domainkey"
  type    = "CNAME"
  ttl     = 1
  content = "fm3.${each.key}.dkim.fmhosted.com"
}

resource "cloudflare_dns_record" "mesmtp" {
  for_each = local.enable_email

  zone_id = cloudflare_zone.this[each.key].id
  name    = "mesmtp._domainkey"
  type    = "CNAME"
  ttl     = 1
  content = "mesmtp.${each.key}.dkim.fmhosted.com"
}

resource "cloudflare_dns_record" "spf" {
  for_each = local.enable_email

  zone_id = cloudflare_zone.this[each.key].id
  name    = "@"
  type    = "TXT"
  ttl     = 1
  content = "v=spf1 include:spf.messagingengine.com ?all"
}

resource "cloudflare_dns_record" "disable_email_spf" {
  for_each = local.disable_email

  zone_id = cloudflare_zone.this[each.key].id
  name    = "@"
  type    = "TXT"
  ttl     = 1
  content = "v=spf1 -all"
}

resource "cloudflare_dns_record" "dmarc" {
  for_each = local.enable_email

  zone_id = cloudflare_zone.this[each.key].id
  name    = "_dmarc"
  type    = "TXT"
  ttl     = 1
  content = "v=DMARC1; p=reject; rua=mailto:${each.value.rua}"
}

resource "cloudflare_dns_record" "smtp_tls_reporting" {
  for_each = local.enable_email

  zone_id = cloudflare_zone.this[each.key].id
  name    = "_smtp._tls"
  type    = "TXT"
  ttl     = 1
  content = "v=TLSRPTv1; rua=mailto:${each.value.rua}"
}

resource "cloudflare_dns_record" "mta_sts" {
  for_each = local.enable_email

  zone_id = cloudflare_zone.this[each.key].id
  name    = "_mta-sts"
  type    = "TXT"
  ttl     = 1
  content = "\"v=STSv1; id=20221120;\""
}

resource "cloudflare_dns_record" "submission" {
  for_each = local.enable_email

  zone_id = cloudflare_zone.this[each.key].id
  name    = "_submission._tcp"
  type    = "SRV"
  ttl     = 1

  data = {
    service  = "_submission"
    proto    = "_tcp"
    name     = "smtp"
    priority = 0
    weight   = 0
    port     = 0
    target   = "."
  }
}

resource "cloudflare_dns_record" "submissions" {
  for_each = local.enable_email

  zone_id = cloudflare_zone.this[each.key].id
  name    = "_submissions._tcp"
  type    = "SRV"
  ttl     = 1

  data = {
    service  = "_submissions"
    proto    = "_tcp"
    name     = "smtp"
    priority = 0
    weight   = 1
    port     = 465
    target   = "smtp.fastmail.com"
  }
}

resource "cloudflare_dns_record" "imap" {
  for_each = local.enable_email

  zone_id = cloudflare_zone.this[each.key].id
  name    = "_imap._tcp"
  type    = "SRV"
  ttl     = 1

  data = {
    service  = "_imap"
    proto    = "_tcp"
    name     = "imap"
    priority = 0
    weight   = 0
    port     = 0
    target   = "."
  }
}

resource "cloudflare_dns_record" "imaps" {
  for_each = local.enable_email

  zone_id = cloudflare_zone.this[each.key].id
  name    = "_imaps._tcp"
  type    = "SRV"
  ttl     = 1

  data = {
    service  = "_imaps"
    proto    = "_tcp"
    name     = "imaps"
    priority = 0
    weight   = 1
    port     = 993
    target   = "imap.fastmail.com"
  }
}

resource "cloudflare_dns_record" "pop3" {
  for_each = local.enable_email

  zone_id = cloudflare_zone.this[each.key].id
  name    = "_pop3._tcp"
  type    = "SRV"
  ttl     = 1

  data = {
    service  = "_pop3"
    proto    = "_tcp"
    name     = "pop3"
    priority = 0
    weight   = 0
    port     = 0
    target   = "."
  }
}

resource "cloudflare_dns_record" "pop3s" {
  for_each = local.enable_email

  zone_id = cloudflare_zone.this[each.key].id
  name    = "_pop3s._tcp"
  type    = "SRV"
  ttl     = 1

  data = {
    service  = "_pop3s"
    proto    = "_tcp"
    name     = "pop3s"
    priority = 10
    weight   = 1
    port     = 995
    target   = "pop.fastmail.com"
  }
}

resource "cloudflare_dns_record" "jmap" {
  for_each = local.enable_email

  zone_id = cloudflare_zone.this[each.key].id
  name    = "_jmap._tcp"
  type    = "SRV"
  ttl     = 1

  data = {
    service  = "_jmap"
    proto    = "_tcp"
    name     = "jmap"
    priority = 0
    weight   = 1
    port     = 443
    target   = "jmap.fastmail.com"
  }
}

resource "cloudflare_dns_record" "autodiscover" {
  for_each = local.enable_email

  zone_id = cloudflare_zone.this[each.key].id
  name    = "_autodiscover._tcp"
  type    = "SRV"
  ttl     = 1

  data = {
    service  = "_autodiscover"
    proto    = "_tcp"
    name     = "autodiscover"
    priority = 0
    weight   = 1
    port     = 443
    target   = "autodiscover.fastmail.com"
  }
}

resource "cloudflare_dns_record" "carddav" {
  for_each = local.enable_email

  zone_id = cloudflare_zone.this[each.key].id
  name    = "_carddav._tcp"
  type    = "SRV"
  ttl     = 1

  data = {
    service  = "_carddav"
    proto    = "_tcp"
    name     = "carddav"
    priority = 0
    weight   = 0
    port     = 0
    target   = "."
  }
}

resource "cloudflare_dns_record" "carddavs" {
  for_each = local.enable_email

  zone_id = cloudflare_zone.this[each.key].id
  name    = "_carddavs._tcp"
  type    = "SRV"
  ttl     = 1

  data = {
    service  = "_carddavs"
    proto    = "_tcp"
    name     = "carddavs"
    priority = 0
    weight   = 1
    port     = 443
    target   = "carddav.fastmail.com"
  }
}

resource "cloudflare_dns_record" "caldav" {
  for_each = local.enable_email

  zone_id = cloudflare_zone.this[each.key].id
  name    = "_caldav._tcp"
  type    = "SRV"
  ttl     = 1

  data = {
    service  = "_caldav"
    proto    = "_tcp"
    name     = "caldav"
    priority = 0
    weight   = 0
    port     = 0
    target   = "."
  }
}

resource "cloudflare_dns_record" "caldavs" {
  for_each = local.enable_email

  zone_id = cloudflare_zone.this[each.key].id
  name    = "_caldavs._tcp"
  type    = "SRV"
  ttl     = 1

  data = {
    service  = "_caldavs"
    proto    = "_tcp"
    name     = "caldavs"
    priority = 0
    weight   = 1
    port     = 443
    target   = "caldav.fastmail.com"
  }
}
