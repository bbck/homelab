terraform {
  backend "local" {
    path = "./.terraform/terraform.tfstate"
  }
}

provider "cloudflare" {}
