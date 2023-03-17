resource "cloudflare_zone" "cheatycheetahs_dot_com" {
  account_id = var.cloudflare_account_id
  zone       = "cheatycheetahs.com"
}

module "cheatycheetahs_dot_com_fastmail" {
  source = "./modules/fastmail"

  cloudflare_account_id = var.cloudflare_account_id
  domain                = cloudflare_zone.cheatycheetahs_dot_com.zone
  zone_id               = cloudflare_zone.cheatycheetahs_dot_com.id
}
