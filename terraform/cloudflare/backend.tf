terraform {
  backend "s3" {
    bucket = "terraform"
    key    = "cloudflare/cloudflare.tfstate"
    region = "auto"

    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    use_path_style              = true
    use_lockfile                = true
  }
}
