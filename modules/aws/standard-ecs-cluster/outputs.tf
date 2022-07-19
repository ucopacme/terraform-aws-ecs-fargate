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
  value       = module.ecs_task_def.family
}
    
output "revision" {
  description = "The revision of the task in a particular family"
  value       = module.ecs_task_def.revision
}

output "target_group_arns" {
  description = "ARNs of the target groups. Useful for passing to your Auto Scaling group."
  value       = module.alb.target_group_arns
}
output "https_listener_arns" {
  description = "The ARNs of the HTTPS load balancer listeners created."
  value       = module.alb.https_listener_arns
}
output "http_tcp_listener_arns" {
  description = "The ARNs of the HTTPS load balancer listeners created."
  value       = module.alb.https_listener_arns
}
