variable "cloudflare_api_token" {
  type = string
}

variable "cloudflare_account_id" {
  type = string
}

variable "domains" {
  type = map(object({
    email = bool
    rua   = string

    # https://github.com/cloudflare/terraform-provider-cloudflare/issues/5134
    route_id = string
  }))
}
