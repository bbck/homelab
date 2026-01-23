terraform {
  required_providers {
    onepassword = {
      source  = "1Password/onepassword"
      version = "3.1.2"
    }

    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "5.16.0"
    }
  }
}

provider "onepassword" {
  connect_url   = var.op_connect_host
  connect_token = var.op_connect_token
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
