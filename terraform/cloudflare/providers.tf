terraform {
  required_version = "~> 1.12"

  required_providers {
    onepassword = {
      source  = "1Password/onepassword"
      version = "3.3.1"
    }

    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "5.24.0"
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

ephemeral "onepassword_item" "cloudflare" {
  vault = data.onepassword_vault.homelab.uuid
  title = "cloudflare-terraform"
}

provider "cloudflare" {
  api_token = ephemeral.onepassword_item.cloudflare.credential
}

data "onepassword_item" "cloudflare_account" {
  vault = data.onepassword_vault.homelab.uuid
  title = "cloudflare-account"
}
