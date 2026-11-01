locals {
  account   = "com.cloudflare.api.account.${local.account_id}"
  all_zones = { (local.account) = { "com.cloudflare.api.account.zone.*" = "*" } }

  api_tokens = {
    terraform = [
      {
        permissions = ["Account API Tokens Write", "Account API Tokens Read"]
        resources   = { (local.account) = "*" }
      },
      {
        permissions = ["Workers R2 Storage Write", "Workers R2 Storage Read", "Workers Scripts Write", "Workers Scripts Read"]
        resources   = { (local.account) = "*" }
      },
      {
        permissions = ["DNS Read", "Workers Routes Write", "Workers Routes Read", "DNS Write"]
        resources   = local.all_zones
      },
    ]
    terraform-r2 = [
      {
        permissions = ["Workers R2 Storage Bucket Item Write"]
        resources   = { "com.cloudflare.edge.r2.bucket.${local.account_id}_default_${cloudflare_r2_bucket.terraform.name}" = "*" }
      },
    ]
    kopiur-r2 = [
      {
        permissions = ["Workers R2 Storage Bucket Item Write"]
        resources   = { "com.cloudflare.edge.r2.bucket.${local.account_id}_default_${cloudflare_r2_bucket.k8s_backups.name}" = "*" }
      },
    ]
    dns = [
      {
        permissions = ["Zone Read", "DNS Write"]
        resources   = { "com.cloudflare.api.account.zone.${cloudflare_zone.this["bbck.dev"].id}" = "*" }
      },
    ]
  }

  permission_groups = {
    for group in data.cloudflare_account_api_token_permission_groups_list.this.result :
    group.name => group.id...
  }
}

data "cloudflare_account_api_token_permission_groups_list" "this" {
  account_id = local.account_id
}

resource "cloudflare_account_token" "this" {
  for_each = local.api_tokens

  account_id = local.account_id
  name       = each.key
  policies = [
    for policy in each.value : {
      effect = "allow"
      # Cloudflare stores them sorted by ID
      permission_groups = [
        for id in sort([for name in policy.permissions : one(local.permission_groups[name])]) : { id = id }
      ]
      resources = jsonencode(policy.resources)
    }
  ]

  lifecycle {
    prevent_destroy = true
  }
}
