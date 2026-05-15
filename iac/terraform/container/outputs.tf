# App stack outputs
output "backend_sg" {
  value = module.backend_sg.security_group_id
}
output "todo_cluster_arn" {
  value = module.ecs.cluster_arn
}
output "todo_cluster_name" {
  value = module.ecs.cluster_name
}
output "frontend_repo_name" {
  value = module.frontend_repo.repository_name
}
output "frontend_service_name" {
  value = module.ecs.services["todo-frontend-task"].name
}
output "frontend_service_arn" {
  value = module.ecs.services["todo-frontend-task"].id
}
output "backend_repo_name" {
  value = module.backend_repo.repository_name
}
output "backend_service_name" {
  value = module.ecs.services["todo-backend-task"].name
}
output "backend_service_arn" {
  value = module.ecs.services["todo-backend-task"].id
}

# Monitoring stack outputs
output "prom_repo_name" {
  value = module.prom_repo.repository_name
}
output "graf_repo_name" {
  value = module.graf_repo.repository_name
}
output "mno_cluster_arn" {
  value = module.ecs_monitoring.cluster_arn
}
output "mno_cluster_name" {
  value = module.ecs_monitoring.cluster_name
}
output "mno_service_arn" {
  value = module.ecs_monitoring.services["todo-mno-task"].id
}
output "mno_service_name" {
  value = module.ecs_monitoring.services["todo-mno-task"].name
}
