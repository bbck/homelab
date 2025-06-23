locals {
  fields = merge([
    for section in data.onepassword_item.cloudflare.section : merge([
      for field in section.field : { "${field.label}" = field.value }
    ]...)
  ]...)

  account_id = local.fields["account_id"]

  enable_email = {
    for k, v in var.domains : k => v
    if v.email
  }
  disable_email = {
    for k, v in var.domains : k => v
    if !v.email
  }
}

