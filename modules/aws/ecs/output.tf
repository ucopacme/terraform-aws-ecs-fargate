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

output "execution_role" {
  description = "ARN of IAM role"
  value       = aws_iam_role.execution_role.arn
}
