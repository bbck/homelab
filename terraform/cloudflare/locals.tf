locals {
  account_id = data.onepassword_item.cloudflare_account.username

  enable_email = {
    for k, v in var.domains : k => v
    if v.email
  }
  disable_email = {
    for k, v in var.domains : k => v
    if !v.email
  }
}

