terraform {
  required_providers {
    onepassword = {
      source  = "1Password/onepassword"
      version = "3.2.1"
    }

    minio = {
      source  = "aminueza/minio"
      version = "3.15.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.8.1"
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

data "onepassword_item" "minio" {
  vault = data.onepassword_vault.homelab.uuid
  title = "minio"
}

provider "minio" {
  minio_server   = var.minio_server
  minio_ssl      = true
  minio_user     = data.onepassword_item.minio.username
  minio_password = data.onepassword_item.minio.password
}
