resource "cloudflare_zone" "lookitupongoogle_dot_com" {
  account_id = var.cloudflare_account_id
  zone       = "lookitupongoogle.com"
}

module "lookitupongoogle_dot_com_disable_email" {
  source  = "./modules/disable-email"
  domain  = cloudflare_zone.lookitupongoogle_dot_com.zone
  zone_id = cloudflare_zone.lookitupongoogle_dot_com.id
}

module "lookitupongoogle_dot_com" {
  source                = "./modules/lookitupongoogle"
  cloudflare_account_id = var.cloudflare_account_id
}
