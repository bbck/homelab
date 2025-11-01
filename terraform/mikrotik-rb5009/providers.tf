terraform {
  required_providers {
    onepassword = {
      source  = "1Password/onepassword"
      version = "2.2.0"
    }

    routeros = {
      source  = "terraform-routeros/routeros"
      version = "1.90.0"
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

data "onepassword_item" "routeros" {
  vault = data.onepassword_vault.homelab.uuid
  title = "routeros-terraform"
}

provider "routeros" {
  hosturl  = var.routeros_host
  insecure = true
  username = data.onepassword_item.routeros.username
  password = data.onepassword_item.routeros.password
}
