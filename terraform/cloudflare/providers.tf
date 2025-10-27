terraform {
  required_providers {
    onepassword = {
      source  = "1Password/onepassword"
      version = "2.2.0"
    }

    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "5.11.0"
    }
  }
}

provider "onepassword" {
  url   = var.op_connect_host
  token = var.op_connect_token
}

data "onepassword_vault" "homelab" {
  name = "Homelab"
}

data "onepassword_item" "cloudflare" {
  vault = data.onepassword_vault.homelab.uuid
  title = "cloudflare"
}

provider "cloudflare" {
  api_token = local.fields["terraform"]
}
