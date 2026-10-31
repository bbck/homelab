terraform {
  required_version = "~> 1.12"

  required_providers {
    onepassword = {
      source  = "1Password/onepassword"
      version = "3.4.1"
    }

    routeros = {
      source  = "terraform-routeros/routeros"
      version = "1.99.1"
    }
  }
}

provider "onepassword" {
  # tofu-controller uses the in-cluster Connect server. To run tofu locally,
  # leave op_connect_token unset and set OP_ACCOUNT to use the 1Password app.
  connect_url   = var.op_connect_token == null ? null : var.op_connect_host
  connect_token = var.op_connect_token
}

data "onepassword_vault" "homelab" {
  name = "Homelab"
}

ephemeral "onepassword_item" "routeros" {
  vault = data.onepassword_vault.homelab.uuid
  title = "routeros-terraform"
}

provider "routeros" {
  hosturl  = var.routeros_host
  insecure = true
  username = ephemeral.onepassword_item.routeros.username
  password = ephemeral.onepassword_item.routeros.password
}
