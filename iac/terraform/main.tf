terraform {
  required_version = ">= 1.14.8"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile

  default_tags {
    tags = {
      Environment = "Practice"
      ManagedBy   = "Terraform"
      Project     = "TodoApp"
    }
  }
}

module "networks" {
  source = "./networks"

  aws_region = var.aws_region
  vpc_cidr   = "10.0.0.0/20"
  ssm_rds_sg = module.database.ssm_rds_sg
}

module "database" {
  source = "./database"

  backend_sg      = module.container.backend_sg
  vpc             = module.networks.vpc
  my_ip           = var.my_ip
  private_subnets = module.networks.private_subnets
}

module "load_balancer" {
  source = "./load-balancer"

  vpc            = module.networks.vpc
  public_subnets = module.networks.pubic_subnets
  acm_arn        = "arn:aws:acm:us-east-2:131912109503:certificate/3f2971ec-a640-4a4d-8c86-5a67a803d284"
}

module "container" {
  source = "./container"

  tag_policy        = "IMMUTABLE_WITH_EXCLUSION"
  alb_sg            = module.load_balancer.alb_sg
  vpc               = module.networks.vpc
  private_subnets   = module.networks.private_subnets
  alb_tg            = module.load_balancer.alb_tg
  todo_env_policy   = module.iam.todo_env_policy
  todo_files_policy = module.iam.todo_files_policy
  s3_files_name     = module.storage.s3_files_name
  s3_env_arn        = module.storage.s3_env_arn
  db_address        = module.database.db_address
  rds_secret_arn    = module.database.rds_secret_arn
}

module "iam" {
  source = "./iam"

  rds_secret_arn = module.database.rds_secret_arn
  s3_env_arn = module.storage.s3_env_arn
  s3_files_arn = module.storage.s3_files_arn
}

module "storage" {
  source = "./storage"

  aws_region = var.aws_region
  alb_dns    = module.load_balancer.alb_dns
}

module "lambda" {
  source = "./lambda"

  todo_cluster_arn = module.container.todo_cluster_arn
  todo_cluster_name = module.container.todo_cluster_name
  frontend_repo_name = module.container.frontend_repo_name
  frontend_service_name = module.container.frontend_service_name
  backend_repo_name = module.container.backend_repo_name
  backend_service_name = module.container.backend_service_name
  frontend_service_arn = module.container.frontend_service_arn
  backend_service_arn = module.container.backend_service_arn
  prom_repo_name = module.container.prom_repo_name
  graf_repo_name = module.container.graf_repo_name
  mno_cluster_arn = module.container.mno_cluster_arn
  mno_cluster_name = module.container.mno_cluster_name
  mno_service_arn = module.container.mno_service_arn
  mno_service_name = module.container.mno_service_name
}