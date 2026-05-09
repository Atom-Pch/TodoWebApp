module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = ">= 10.5.0"

  name               = "todo-app-alb"
  load_balancer_type = "application"

  vpc_id          = var.vpc
  subnets         = var.public_subnets
  security_groups = [module.alb_sg.security_group_id]
  internal        = false

  enable_deletion_protection = false

  target_groups = {
    tg-frontend = {
      protocol = "HTTP"
      port     = 3000
      health_check = {
        enabled = true
        path    = "/"
      }
      target_type       = "ip"
      create_attachment = false
    }

    tg-backend = {
      protocol = "HTTP"
      port     = 8080
      health_check = {
        enabled = true
        path    = "/"
      }
      target_type       = "ip"
      create_attachment = false
    }
  }

  listeners = {
    http_redirect = {
      port     = 80
      protocol = "HTTP"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }

    https = {
      port            = 443
      protocol        = "HTTPS"
      ssl_policy      = "ELBSecurityPolicy-TLS-1-2-2017-01"
      certificate_arn = var.acm_arn
      forward = {
        target_group_key = "tg-frontend"
      }
      rules = {
        api_path = {
          priority = 1
          actions = [{
            forward = {
              target_group_key = "tg-backend"
            }
          }]
          conditions = [{
            path_pattern = {
              values = ["/api*"]
            }
          }]
        }
      }
    }
  }
}
