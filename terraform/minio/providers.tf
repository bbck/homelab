terraform {
  required_providers {
    onepassword = {
      source  = "1Password/onepassword"
      version = "2.1.2"
    }

    minio = {
      source  = "aminueza/minio"
      version = "3.6.5"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.7.2"
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
