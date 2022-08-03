output "cluster_id" {
  description = "The ID of the created ECS cluster."
  value       = aws_ecs_cluster.this.id
}

output "cluster_name" {
  description = "The name of the created ECS cluster."
  value       = aws_ecs_cluster.this.name
}

output "cluster_arn" {
  description = "The ARN of the created ECS cluster."
  value       = aws_ecs_cluster.this.arn
}

output "execution_role_arn" {
  description = "ARN of IAM role"
  value       = aws_iam_role.execution_role.arn
}

output "family" {
  description = "The family of your task definition, used as the definition name"
  value       = join("", aws_ecs_task_definition.this.*.family)
}

output "revision" {
  description = "The revision of the task in a particular family"
  value       = join("", aws_ecs_task_definition.this.*.revision)
}

output "ecs_service_name" {
  value       = join("", aws_ecs_service.this.*.name)
  description = "The name of the service."
}
