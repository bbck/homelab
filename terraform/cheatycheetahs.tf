resource "cloudflare_zone" "cheatycheetahs_dot_com" {
  zone = "cheatycheetahs.com"
}

module "cheatycheetahs_dot_com_fastmail" {
  source = "./fastmail"

  domain = "cheatycheetahs.com"
  zone_id = cloudflare_zone.cheatycheetahs_dot_com.id
}
