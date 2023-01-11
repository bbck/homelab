terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "bbck"

    workspaces {
      name = "homelab"
    }
  }
}

provider "cloudflare" {}
