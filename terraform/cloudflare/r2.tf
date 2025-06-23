resource "cloudflare_r2_bucket" "k8s_backups" {
  account_id    = local.account_id
  name          = "k8s-backups"
  location      = "WNAM"
  storage_class = "Standard"

  lifecycle {
    prevent_destroy = true
  }
}
