resource "cloudflare_zone" "lookitupongoogle_dot_com" {
  zone = "lookitupongoogle.com"
}

module "lookitupongoogle_dot_com_fastmail" {
  source = "./fastmail"

  domain        = "lookitupongoogle.com"
  zone_id       = cloudflare_zone.lookitupongoogle_dot_com.id
  email_delivery = false
}

resource "cloudflare_record" "lookitupongoogle_dot_com_root" {
  zone_id = cloudflare_zone.lookitupongoogle_dot_com.id
  name    = "lookitupongoogle.com"
  value   = "google.com"
  type    = "CNAME"
  proxied = true
}

resource "cloudflare_record" "lookitupongoogle_dot_com_www" {
  zone_id = cloudflare_zone.lookitupongoogle_dot_com.id
  name    = "www"
  value   = "google.com"
  type    = "CNAME"
  proxied = true
}

resource "cloudflare_page_rule" "lookitupongoogle_dot_com_subdomain" {
  zone_id  = cloudflare_zone.lookitupongoogle_dot_com.id
  target   = "*.lookitupongoogle.com/*"
  priority = 1

  actions {
    forwarding_url {
      status_code = 302
      url         = "https://$1.google.com/$2"
    }
  }
}

resource "cloudflare_page_rule" "lookitupongoogle_dot_com_root" {
  zone_id  = cloudflare_zone.lookitupongoogle_dot_com.id
  target   = "lookitupongoogle.com/*"
  priority = 2

  actions {
    forwarding_url {
      status_code = 302
      url         = "https://google.com/$1"
    }
  }
}
