terraform {
  required_providers {
    onepassword = {
      source  = "1Password/onepassword"
      version = "3.2.1"
    }

    routeros = {
      source  = "terraform-routeros/routeros"
      version = "1.99.0"
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
