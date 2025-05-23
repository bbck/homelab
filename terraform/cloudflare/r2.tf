resource "cloudflare_r2_bucket" "k8s_backups" {
  account_id    = var.cloudflare_account_id
  name          = "k8s-backups"
  location      = "wnam"
  storage_class = "Standard"

  lifecycle {
    prevent_destroy = true
  }
}
