resource "cloudflare_workers_script" "lookitupongoogle" {
  account_id  = local.account_id
  script_name = "lookitupongoogle"
  content     = file("${path.module}/workers/lookitupongoogle.js")
}

resource "cloudflare_workers_custom_domain" "lookitupongoogle_root" {
  account_id  = local.account_id
  environment = "production"
  hostname    = "lookitupongoogle.com"
  service     = cloudflare_workers_script.lookitupongoogle.script_name
  zone_id     = cloudflare_zone.this["lookitupongoogle.com"].id
}

resource "cloudflare_workers_custom_domain" "lookitupongoogle_www" {
  account_id  = local.account_id
  environment = "production"
  hostname    = "www.lookitupongoogle.com"
  service     = cloudflare_workers_script.lookitupongoogle.script_name
  zone_id     = cloudflare_zone.this["lookitupongoogle.com"].id
}

resource "cloudflare_workers_script" "mta_sts" {
  for_each = local.enable_email

  account_id  = local.account_id
  script_name = "mta-sts-${replace(each.key, ".", "-")}"
  content     = file("${path.module}/workers/mta-sts.js")
}

resource "cloudflare_workers_custom_domain" "mta_sts" {
  for_each = local.enable_email

  account_id  = local.account_id
  environment = "production"
  hostname    = "mta-sts.${each.key}"
  service     = cloudflare_workers_script.mta_sts[each.key].script_name
  zone_id     = cloudflare_zone.this[each.key].id
}

resource "cloudflare_workers_route" "mta_sts" {
  for_each = local.enable_email

  zone_id = cloudflare_zone.this[each.key].id
  pattern = "mta-sts.${each.key}/.well-known/mta-sts.txt"
  script  = cloudflare_workers_script.mta_sts[each.key].script_name
}
