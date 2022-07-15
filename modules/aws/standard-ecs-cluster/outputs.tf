output "cluster_id" {
  description = "The ID of the created ECS cluster."
  value       = module.ecs.cluster_id
}

output "cluster_name" {
  description = "The name of the created ECS cluster."
  value       = module.ecs.cluster_name
}

output "cluster_arn" {
  description = "The ARN of the created ECS cluster."
  value       = module.ecs.cluster_arn
}
output "execution_role" {
  description = "ARN of IAM role"
  value       = module.ecs.execution_role.arn
}
