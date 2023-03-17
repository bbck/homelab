variable "cloudflare_account_id" {
  type        = string
  description = "Cloudflare Account ID"
}

variable "domain" {
  type        = string
  description = "Root domain name"
}

variable "zone_id" {
  type        = string
  description = "Cloudflare Zone ID"
}

variable "dmarc_extra" {
  type        = string
  default     = ""
  description = "Additional DMARC content"
}
