terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 2.20.0"
    }
  }

  required_version = "~> 1.2.0"
}
