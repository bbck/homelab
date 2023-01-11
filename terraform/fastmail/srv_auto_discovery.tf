resource "cloudflare_record" "_submission" {
  zone_id = var.zone_id
  name    = "_submission._tcp"
  type    = "SRV"

  data {
    service  = "_submission"
    proto    = "_tcp"
    name     = "smtp.${var.domain}"
    priority = 0
    weight   = 1
    port     = 587
    target   = "smtp.fastmail.com"
  }
}

resource "cloudflare_record" "_imap" {
  zone_id = var.zone_id
  name    = "_imap._tcp"
  type    = "SRV"

  data {
    service  = "_imap"
    proto    = "_tcp"
    name     = "imap.${var.domain}"
    priority = 0
    weight   = 0
    port     = 0
    target   = "."
  }
}

resource "cloudflare_record" "_imaps" {
  zone_id = var.zone_id
  name    = "_imaps._tcp"
  type    = "SRV"

  data {
    service  = "_imaps"
    proto    = "_tcp"
    name     = "imaps.${var.domain}"
    priority = 0
    weight   = 1
    port     = 993
    target   = "imap.fastmail.com"
  }
}

resource "cloudflare_record" "_pop3" {
  zone_id = var.zone_id
  name    = "_pop3._tcp"
  type    = "SRV"

  data {
    service  = "_pop3"
    proto    = "_tcp"
    name     = "pop3.${var.domain}"
    priority = 0
    weight   = 0
    port     = 0
    target   = "."
  }
}

resource "cloudflare_record" "_pop3s" {
  zone_id = var.zone_id
  name    = "_pop3s._tcp"
  type    = "SRV"

  data {
    service  = "_pop3s"
    proto    = "_tcp"
    name     = "pop3s.${var.domain}"
    priority = 10
    weight   = 1
    port     = 995
    target   = "pop.fastmail.com"
  }
}

resource "cloudflare_record" "_jmap" {
  zone_id = var.zone_id
  name    = "_jmap._tcp"
  type    = "SRV"

  data {
    service  = "_jmap"
    proto    = "_tcp"
    name     = "jmap.${var.domain}"
    priority = 0
    weight   = 1
    port     = 443
    target   = "jmap.fastmail.com"
  }
}

resource "cloudflare_record" "_carddav" {
  zone_id = var.zone_id
  name    = "_carddav._tcp"
  type    = "SRV"

  data {
    service  = "_carddav"
    proto    = "_tcp"
    name     = "carddav.${var.domain}"
    priority = 0
    weight   = 0
    port     = 0
    target   = "."
  }
}

resource "cloudflare_record" "_carddavs" {
  zone_id = var.zone_id
  name    = "_carddavs._tcp"
  type    = "SRV"

  data {
    service  = "_carddavs"
    proto    = "_tcp"
    name     = "carddavs.${var.domain}"
    priority = 0
    weight   = 1
    port     = 443
    target   = "carddav.fastmail.com"
  }
}

resource "cloudflare_record" "_caldav" {
  zone_id = var.zone_id
  name    = "_caldav._tcp"
  type    = "SRV"

  data {
    service  = "_caldav"
    proto    = "_tcp"
    name     = "caldav.${var.domain}"
    priority = 0
    weight   = 0
    port     = 0
    target   = "."
  }
}

resource "cloudflare_record" "_caldavs" {
  zone_id = var.zone_id
  name    = "_caldavs._tcp"
  type    = "SRV"

  data {
    service  = "_caldavs"
    proto    = "_tcp"
    name     = "caldavs.${var.domain}"
    priority = 0
    weight   = 1
    port     = 443
    target   = "caldav.fastmail.com"
  }
}
