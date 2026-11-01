variable "op_connect_host" {
  type    = string
  default = "http://onepassword-connect.external-secrets.svc.cluster.local:8080"
}

variable "op_connect_token" {
  type      = string
  sensitive = true
  default   = null
}

variable "routeros_host" {
  type    = string
  default = "apis://192.168.88.3:8729"
}

variable "state_passphrase" {
  type      = string
  sensitive = true
  ephemeral = true
}
