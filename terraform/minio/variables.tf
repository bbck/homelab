variable "minio_server" {
  type    = string
  default = "s3.bbck.dev"
}

variable "minio_username" {
  type      = string
}

variable "minio_password" {
  type      = string
  sensitive = true
}

variable "buckets" {
  type    = set(string)
  default = ["terraform", "k8s-backups", "obsidian"]
}
