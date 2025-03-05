terraform {
  required_providers {
    routeros = {
      source  = "terraform-routeros/routeros"
      version = "1.77.2"
    }
  }
}

provider "routeros" {
  hosturl  = "https://192.168.88.2"
  insecure = true
  username = var.routeros_username
  password = var.routeros_password
}
