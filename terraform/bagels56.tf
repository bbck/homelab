resource "cloudflare_zone" "bagels56_dot_com" {
  account_id = var.cloudflare_account_id
  zone       = "bagels56.com"
}

module "bagels56_dot_com" {
  source                = "./modules/bagels56"
  cloudflare_account_id = var.cloudflare_account_id
}
