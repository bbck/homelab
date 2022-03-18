terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 2.27.0"
    }
  }

  required_version = "~> 1.0.0"
}
