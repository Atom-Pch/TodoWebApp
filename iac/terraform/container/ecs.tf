module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = ">= 7.5.0"

  cluster_name               = "todo-app-cluster"
  cluster_capacity_providers = ["FARGATE"]

  services = {
    todo-frontend-task = {
      cpu           = 512
      memory        = 1024
      desired_count = 1

      container_definitions = {
        frontend-container = {
          image     = "${module.frontend_repo.repository_url}:latest"
          essential = true

          portMappings = [{
            name          = "frontend-container"
            containerPort = 3000
            hostPort      = 3000
            protocol      = "tcp"
          }]
        }
      }

      load_balancer = {
        service = {
          target_group_arn = var.alb_tg["tg-frontend"].arn
          container_name   = "frontend-container"
          container_port   = 3000
        }
      }

      security_group_ids = [module.frontend_sg.security_group_id]
      subnet_ids         = var.private_subnets
      assign_public_ip   = false

      tasks_iam_role_policies = {
        files_policy = var.todo_files_policy
      }

      deployment_circuit_breaker = {
        enable   = true
        rollback = false
      }
    }

    todo-backend-task = {
      cpu           = 512
      memory        = 1024
      desired_count = 1

      container_definitions = {
        backend-container = {
          image     = "${module.backend_repo.repository_url}:latest"
          essential = true

          portMappings = [{
            name          = "backend-container"
            containerPort = 8080
            hostPort      = 8080
            protocol      = "tcp"
          }]

          environment = [
            {
              name  = "DB_HOST"
              value = var.db_address
            },
            {
              name  = "DB_USER"
              value = "atom"
            },
            {
              name  = "DB_NAME"
              value = "todo_db"
            },
            {
              name  = "S3_BUCKET_NAME"
              value = var.s3_files_name
            },
            {
              name  = "AWS_REGION"
              value = "us-east-2"
            }
          ]

          secrets = [{
            name      = "DB_PASS"
            valueFrom = "${var.rds_secret_arn}:password::"
          }]

          environmentFiles = [{
            value = "${var.s3_env_arn}/.env"
            type  = "s3"
          }]
        }
      }

      load_balancer = {
        service = {
          target_group_arn = var.alb_tg["tg-backend"].arn
          container_name   = "backend-container"
          container_port   = 8080
        }
      }

      security_group_ids = [module.backend_sg.security_group_id]
      subnet_ids         = var.private_subnets
      assign_public_ip   = false

      tasks_iam_role_policies = {
        files_policy = var.todo_files_policy
      }

      task_exec_iam_role_policies = {
        env_policy = var.todo_env_policy
      }

      service_registries = {
        registry_arn   = aws_service_discovery_service.backend.arn
        container_name = "backend-container"
      }

      deployment_circuit_breaker = {
        enable   = true
        rollback = false
      }
    }
  }

  create_security_group     = false
  create_task_exec_iam_role = true
  create_task_exec_policy   = true

  create_cloudwatch_log_group = false
}

module "ecs_monitoring" {
  source  = "terraform-aws-modules/ecs/aws"
  version = ">= 7.5.0"

  cluster_name               = "todo-mno-cluster"
  cluster_capacity_providers = ["FARGATE_SPOT"]

  services = {
    todo-mno-task = {
      cpu           = 256
      memory        = 512
      desired_count = 1

      container_definitions = {
        prometheus-container = {
          image                  = "${module.prom_repo.repository_url}:latest"
          essential              = true
          readonlyRootFilesystem = false

          portMappings = [{
            name          = "prometheus-container"
            containerPort = 9090
            protocol      = "tcp"
          }]
        }

        grafana-container = {
          image                  = "${module.graf_repo.repository_url}:latest"
          essential              = true
          readonlyRootFilesystem = false

          portMappings = [{
            name          = "grafana-container"
            containerPort = 6060
            protocol      = "tcp"
          }]

          environment = [
            {
              name  = "GF_SERVER_HTTP_PORT"
              value = "6060"
            },
            {
              name = "GF_AUTH_ANONYMOUS_ENABLED"
              value = "true"
            },
            {
              name  = "GF_SERVER_ROOT_URL",
              value = "https://onlytodo.xyz/grafana/"
            },
            {
              name  = "GF_SERVER_SERVE_FROM_SUB_PATH",
              value = "true"
            }
          ]

          secrets = [{
            name      = "GF_SECURITY_ADMIN_PASSWORD"
            valueFrom = "arn:aws:secretsmanager:us-east-2:131912109503:secret:grafana-admin-password-dQuIPo:GF_SECURITY_ADMIN_PASSWORD::"
          }]
        }
      }

      security_group_ids = [module.monitoring_sg.security_group_id]
      subnet_ids         = var.private_subnets
      assign_public_ip   = false

      load_balancer = {
        service = {
          target_group_arn = var.alb_tg["tg-grafana"].arn
          container_name   = "grafana-container"
          container_port   = 6060
        }
      }
      network_mode = "awsvpc"

      deployment_circuit_breaker = {
        enable   = true
        rollback = false
      }

      task_exec_iam_role_policies = {
        mno_secret_access = aws_iam_policy.mno_secret.arn
      }
    }
  }

  create_security_group     = false
  create_task_exec_iam_role = true
  create_task_exec_policy   = true

  create_cloudwatch_log_group = false
}

# For secrets retrieval
resource "aws_iam_policy" "mno_secret" {
  name        = "MnOSecretAccess"
  description = "Allow Monitoring and Observalibity service to access secrets"

  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Action : [
          "secretsmanager:GetSecretValue"
        ],
        Effect : "Allow",
        Resource : [
          "arn:aws:secretsmanager:us-east-2:131912109503:secret:grafana-admin-password-dQuIPo"
        ]
      }
    ]
  })
}

# Discovery for monitoring
resource "aws_service_discovery_private_dns_namespace" "main" {
  name        = "todo.local"
  description = "Service discovery for to-do app"
  vpc         = var.vpc
}

resource "aws_service_discovery_service" "backend" {
  name = "backend-discovery"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.main.id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }
}

