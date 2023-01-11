resource "cloudflare_record" "mta_sts" {
  zone_id = var.zone_id
  name    = "_mta-sts"
  value   = "v=STSv1; id=20221120;"
  type    = "TXT"
}

resource "cloudflare_workers_kv_namespace" "mta_sts" {
  title = "mta-sts.${var.domain}"
}

resource "cloudflare_worker_script" "mta_sts" {
  name    = "mta-sts-${replace(var.domain, ".", "-")}"
  content = file("${path.module}/mta-sts.js")
}

resource "cloudflare_worker_route" "mta_sts" {
  zone_id     = var.zone_id
  pattern     = "mta-sts.${var.domain}/.well-known/mta-sts.txt"
  script_name = cloudflare_worker_script.mta_sts.name
}
