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
  }))
}
