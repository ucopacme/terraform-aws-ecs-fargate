output "family" {
  description = "The family of your task definition, used as the definition name"
  value       = join("", aws_ecs_task_definition.this.*.family)
}

output "revision" {
  description = "The revision of the task in a particular family"
  value       = join("", aws_ecs_task_definition.this.*.revision)
}

output "target_group_arns" {
  description = "ARNs of the target groups. Useful for passing to your Auto Scaling group."
  value       = module.alb.target_group_arns
}
