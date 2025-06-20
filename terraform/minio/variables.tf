variable "op_connect_host" {
  type    = string
  default = "http://onepassword-connect.external-secrets.svc.cluster.local:8080"
}

variable "op_connect_token" {
  type      = string
  sensitive = true
}

variable "minio_server" {
  type    = string
  default = "s3.bbck.dev"
}

variable "buckets" {
  type    = set(string)
  default = ["terraform", "k8s-backups", "obsidian"]
}
