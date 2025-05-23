terraform {
  required_providers {
    minio = {
      source  = "aminueza/minio"
      version = "3.5.2"
    }

    random = {
      source = "hashicorp/random"
      version = "3.7.2"
    }
  }
}

provider "minio" {
  minio_server   = var.minio_server
  minio_ssl      = true
  minio_user     = var.minio_username
  minio_password = var.minio_password
}
