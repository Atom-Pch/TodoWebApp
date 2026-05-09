module "alb_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = ">= 5.3.1"

  name        = "todo-alb-sg"
  description = "Allow todo ALB to receive connections from the internet"
  vpc_id      = var.vpc

  ingress_rules = ["http-80-tcp", "https-443-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]

  egress_rules  = ["all-tcp"]
  egress_cidr_blocks = ["0.0.0.0/0"]
}
