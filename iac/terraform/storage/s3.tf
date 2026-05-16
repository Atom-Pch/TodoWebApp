data "aws_caller_identity" "current" {}

module "todo_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = ">= 5.12.0"

  bucket           = format("todo-files-%s-%s-an", data.aws_caller_identity.current.account_id, var.aws_region)
  bucket_namespace = "account-regional"

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  force_destroy = true
}

resource "aws_s3_bucket_cors_configuration" "this" {
  bucket = module.todo_bucket.s3_bucket_id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "PUT", "DELETE"]
    allowed_origins = [
      "http://localhost:5173",
      "http://localhost:3000",
      "http://${var.alb_dns}",
      "https://onlytodo.xyz"
    ]
    max_age_seconds = 3600
  }
}
