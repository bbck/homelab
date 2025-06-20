resource "minio_s3_bucket" "this" {
  for_each = var.buckets

  bucket = each.value
  acl    = "private"

  lifecycle {
    prevent_destroy = true
  }
}

resource "random_password" "this" {
  for_each = var.buckets

  length = 32
}

resource "onepassword_item" "this" {
  for_each = var.buckets

  vault    = data.onepassword_vault.homelab.uuid
  title    = "${each.key}-bucket"
  category = "login"
  username = each.key
  password = random_password.this[each.key].result
}

resource "minio_iam_user" "this" {
  for_each = var.buckets

  name   = each.key
  secret = random_password.this[each.key].result
}

data "minio_iam_policy_document" "this" {
  for_each = var.buckets

  statement {
    actions = [
      "s3:*"
    ]
    resources = [
      "arn:aws:s3:::${each.value}",
      "arn:aws:s3:::${each.value}/*",
    ]
  }
}

resource "minio_iam_policy" "this" {
  for_each = var.buckets

  name   = each.key
  policy = data.minio_iam_policy_document.this[each.key].json
}

resource "minio_iam_user_policy_attachment" "this" {
  for_each = var.buckets

  user_name   = minio_iam_user.this[each.value].id
  policy_name = minio_iam_policy.this[each.value].id
}
