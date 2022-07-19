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
output "execution_role_arn" {
  description = "ARN of IAM role"
  value       = module.ecs.execution_role_arn
}


output "family" {
  description = "The family of your task definition, used as the definition name"
  value       = module.ecs-task-def.family
}
    
    output "revision" {
  description = "The revision of the task in a particular family"
  value       = module.ecs-task-def.this.*.revision
}
