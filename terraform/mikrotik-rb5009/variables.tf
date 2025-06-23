variable "op_connect_host" {
  type    = string
  default = "http://onepassword-connect.external-secrets.svc.cluster.local:8080"
}

variable "op_connect_token" {
  type      = string
  sensitive = true
}

variable "routeros_host" {
  type    = string
  default = "https://192.168.88.2"
}
