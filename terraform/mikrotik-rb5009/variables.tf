variable "op_connect_host" {
  type    = string
  default = "http://onepassword-connect.external-secrets.svc.cluster.local:8080"
}

variable "op_connect_token" {
  type      = string
  sensitive = true
  default   = null
}

# API-SSL, the same as mktxp uses
variable "routeros_host" {
  type    = string
  default = "apis://192.168.88.2:8729"
}
