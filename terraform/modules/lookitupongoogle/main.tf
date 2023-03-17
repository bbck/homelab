resource "cloudflare_worker_script" "this" {
  account_id = var.cloudflare_account_id
  name       = "lookitupongoogle"
  content    = file("${path.module}/worker.js")
}

# TODO: Custom domain routing
# https://github.com/cloudflare/terraform-provider-cloudflare/issues/1921
