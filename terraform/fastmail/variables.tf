variable "domain" {
  type = string
}

variable "zone_id" {
  type = string
}

variable "disable_email" {
  type    = bool
  default = false
}

variable "dmarc_extra" {
  type    = string
  default = ""
}
