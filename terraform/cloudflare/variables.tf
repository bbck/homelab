variable "op_connect_host" {
  type    = string
  default = "http://onepassword-connect.external-secrets.svc.cluster.local:8080"
}

variable "op_connect_token" {
  type      = string
  sensitive = true
}

variable "domains" {
  type = map(object({
    email = bool
    rua   = string
  }))
  default = {
    "bbck.dev" = {
      email = true
      rua   = "null@bbck.dev"
    },
    "bbck.net" = {
      email = true
      rua   = "478fff8e@in.mailhardener.com"
    },
    "cheatycheetahs.com" = {
      email = true
      rua   = "null@cheatycheetahs.com"
    },
    "lookitupongoogle.com" = {
      email = false
      rua   = null
    },
  }
}
