terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 3.32"
    }
  }

  required_version = "~> 1.3.0"
}
