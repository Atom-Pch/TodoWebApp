variable "tag_policy" {
  description = "ECR tags policy"
}
variable "alb_sg" {
  description = "ALB security group for containers"
}
variable "vpc" {
  description = "todo vpc"
}
variable "private_subnets" {
  description = "private subnets for RDS"
}
variable "alb_tg" {
  description = "ALB target group arn"
}
variable "todo_files_policy" {
  description = "IAM policy for S3 access files"
}
variable "s3_files_name" {
  description = "name of todo files S3 bucket"
}
variable "db_address" {
  description = "address of todo RDS"
}
variable "rds_secret_arn" {
  description = "RDS secrets ARN from Secret Manager"
}
variable "todo_app_secret_arn" {
  description = "ARN of app secrets"
}
