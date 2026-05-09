variable "vpc" {
  description = "todo VPC"
}
variable "public_subnets" {
  description = "public subnets for ALB"
}
variable "acm_arn" {
  description = "The ARN of the imported ACM Certificate"
  type        = string
}