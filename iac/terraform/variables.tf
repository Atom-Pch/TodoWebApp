variable "aws_region" {
  description = "AWS region"
  default     = "us-east-2"
}
variable "todo-app-secret-arn" {
  default = "arn:aws:secretsmanager:us-east-2:131912109503:secret:todo-app-secrets-14Gg8G"
}
