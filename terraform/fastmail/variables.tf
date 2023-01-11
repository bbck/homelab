variable "domain" {
  type = string
}

variable "zone_id" {
  type = string
}

variable "email_delivery" {
  type    = bool
  default = true
}

variable "dmarc_extra" {
  type    = string
  default = ""
}
