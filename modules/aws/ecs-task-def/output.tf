output "family" {
  description = "The family of your task definition, used as the definition name"
  value       = join("", aws_ecs_task_definition.this.*.family)
}