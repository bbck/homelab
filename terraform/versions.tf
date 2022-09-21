terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 3.21.0"
    }
  }

  required_version = "~> 1.3.0"
}
