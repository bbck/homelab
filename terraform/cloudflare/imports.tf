import {
  for_each = {
    terraform    = "c2977caba8d6fab00334595dd583560e"
    terraform-r2 = "20feddd28eca3ab7e935bf1ea6884a09"
    kopiur-r2    = "be5c9061f7702ab5472a651e39f71576"
    dns          = "9937598c04c3690bc164bc863611fb18"
  }

  to = cloudflare_account_token.this[each.key]
  id = "${local.account_id}/${each.value}"
}
