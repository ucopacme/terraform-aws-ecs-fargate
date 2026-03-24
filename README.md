## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ecs-autoscaling"></a> [ecs-autoscaling](#module\_ecs-autoscaling) | git::https://git@github.com/ucopacme/terraform-aws-ecs-fargate-auto-scaling | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.exec](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_ecs_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster) | resource |
| [aws_ecs_service.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_iam_policy.task_get_secret_values](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.execution_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.task_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.ecs_exec_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.execution_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.task_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.execution_role_get_secret_values](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.execution_role_managed_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.task_role_get_secret_values](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_ecs_task_definition.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ecs_task_definition) | data source |
| [aws_iam_policy.AmazonECSTaskExecutionRolePolicy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy) | data source |
| [aws_iam_policy_document.assume_by_ecs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.assume_by_ecs_with_source_account](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.task_get_all_secret_values](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.task_get_tagged_secret_values](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_assign_public_ip"></a> [assign\_public\_ip](#input\_assign\_public\_ip) | Assign a public IP address to the ENI | `bool` | `false` | no |
| <a name="input_awslogs_stream_prefix"></a> [awslogs\_stream\_prefix](#input\_awslogs\_stream\_prefix) | CloudWatch Logs log stream prefix for ECS task logs. | `string` | `"container"` | no |
| <a name="input_blue_green"></a> [blue\_green](#input\_blue\_green) | Whether to use blue/green deployment with CODE\_DEPLOY controller and ALB. Set to false for standard rolling deployment without ALB. | `bool` | `true` | no |
| <a name="input_cluster_arn"></a> [cluster\_arn](#input\_cluster\_arn) | name, to be used as prefix for all resource names | `string` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The resource name. | `string` | `null` | no |
| <a name="input_containerInsights"></a> [containerInsights](#input\_containerInsights) | Enables container insights if true | `bool` | `false` | no |
| <a name="input_container_cpu"></a> [container\_cpu](#input\_container\_cpu) | How much CPU to give the container. 1024 is 1 CPU | `number` | `null` | no |
| <a name="input_container_memory"></a> [container\_memory](#input\_container\_memory) | How much memory in megabytes to give the container | `number` | `null` | no |
| <a name="input_container_name"></a> [container\_name](#input\_container\_name) | Name of the container to associate with the load balancer | `string` | `""` | no |
| <a name="input_container_port"></a> [container\_port](#input\_container\_port) | Port that the container exposes. | `number` | n/a | yes |
| <a name="input_cpu"></a> [cpu](#input\_cpu) | task df cpu | `string` | n/a | yes |
| <a name="input_deployment_maximum_percent"></a> [deployment\_maximum\_percent](#input\_deployment\_maximum\_percent) | n/a | `string` | n/a | yes |
| <a name="input_deployment_minimum_healthy_percent"></a> [deployment\_minimum\_healthy\_percent](#input\_deployment\_minimum\_healthy\_percent) | n/a | `string` | n/a | yes |
| <a name="input_desired_count"></a> [desired\_count](#input\_desired\_count) | Number of instances of the task definition to place and keep running | `number` | `0` | no |
| <a name="input_efs_volumes"></a> [efs\_volumes](#input\_efs\_volumes) | Volumes definitions | <pre>list(object({<br/>    name            = string<br/>    file_system_id  = string<br/>    root_directory  = string<br/>    mount_point     = string<br/>    readOnly        = bool<br/>    access_point_id = string<br/>  }))</pre> | `[]` | no |
| <a name="input_enable_autoscaling"></a> [enable\_autoscaling](#input\_enable\_autoscaling) | (Optional) If true, autoscaling alarms will be created. | `bool` | `true` | no |
| <a name="input_enable_deployment_circuit_breaker"></a> [enable\_deployment\_circuit\_breaker](#input\_enable\_deployment\_circuit\_breaker) | Enable deployment circuit breaker with automatic rollback. Only applies when blue\_green = false (ECS rolling deployment). | `bool` | `true` | no |
| <a name="input_enable_ecs_cluster"></a> [enable\_ecs\_cluster](#input\_enable\_ecs\_cluster) | Set to false to prevent the module from creating ecs cluster | `bool` | `true` | no |
| <a name="input_enable_execute_command"></a> [enable\_execute\_command](#input\_enable\_execute\_command) | Enable ECS Exec, and include IAM actions needed for ECS Exec in task role inline policy | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | List of port objects that the container exposes in addition to the task\_container\_port. | <pre>list(object({<br/>    name  = string<br/>    value = string<br/>  }))</pre> | `[]` | no |
| <a name="input_exec_log_group_name"></a> [exec\_log\_group\_name](#input\_exec\_log\_group\_name) | The name of the provided CloudWatch Logs log group to use for ECS Exec logs. | `string` | `""` | no |
| <a name="input_health_check_grace_period_seconds"></a> [health\_check\_grace\_period\_seconds](#input\_health\_check\_grace\_period\_seconds) | Seconds to ignore failing load balancer health checks on newly instantiated tasks. Only applies when blue\_green = true. | `number` | `0` | no |
| <a name="input_image"></a> [image](#input\_image) | Task def image name | `string` | n/a | yes |
| <a name="input_linux_parameters"></a> [linux\_parameters](#input\_linux\_parameters) | Linux-specific modifications that are applied to the container, such as Linux kernel capabilities. | <pre>object({<br/>    initProcessEnabled = bool<br/>  })</pre> | `null` | no |
| <a name="input_max_cpu_evaluation_period"></a> [max\_cpu\_evaluation\_period](#input\_max\_cpu\_evaluation\_period) | The number of periods over which data is compared to the specified threshold for max cpu metric alarm | `string` | `"3"` | no |
| <a name="input_max_cpu_period"></a> [max\_cpu\_period](#input\_max\_cpu\_period) | The period in seconds over which the specified statistic is applied for max cpu metric alarm | `string` | `"60"` | no |
| <a name="input_max_cpu_threshold"></a> [max\_cpu\_threshold](#input\_max\_cpu\_threshold) | Threshold for max CPU usage | `string` | `"85"` | no |
| <a name="input_memory"></a> [memory](#input\_memory) | task df memory | `string` | n/a | yes |
| <a name="input_min_cpu_evaluation_period"></a> [min\_cpu\_evaluation\_period](#input\_min\_cpu\_evaluation\_period) | The number of periods over which data is compared to the specified threshold for min cpu metric alarm | `string` | `"3"` | no |
| <a name="input_min_cpu_period"></a> [min\_cpu\_period](#input\_min\_cpu\_period) | The period in seconds over which the specified statistic is applied for min cpu metric alarm | `string` | `"60"` | no |
| <a name="input_min_cpu_threshold"></a> [min\_cpu\_threshold](#input\_min\_cpu\_threshold) | Threshold for min CPU usage | `string` | `"10"` | no |
| <a name="input_mount_points"></a> [mount\_points](#input\_mount\_points) | List of mount points | `list(any)` | `[]` | no |
| <a name="input_name"></a> [name](#input\_name) | name, to be used as prefix for all resource names | `string` | n/a | yes |
| <a name="input_privileged"></a> [privileged](#input\_privileged) | When this parameter is true, the container is given elevated privileges on the host container instance | `bool` | `false` | no |
| <a name="input_readonlyRootFilesystem"></a> [readonlyRootFilesystem](#input\_readonlyRootFilesystem) | When this parameter is true, the container is given read-only access to its root file system | `bool` | `false` | no |
| <a name="input_retention_in_days"></a> [retention\_in\_days](#input\_retention\_in\_days) | log group retention. | `number` | `30` | no |
| <a name="input_scale_target_max_capacity"></a> [scale\_target\_max\_capacity](#input\_scale\_target\_max\_capacity) | The max capacity of the scalable target | `number` | `2` | no |
| <a name="input_scale_target_min_capacity"></a> [scale\_target\_min\_capacity](#input\_scale\_target\_min\_capacity) | The min capacity of the scalable target | `number` | `1` | no |
| <a name="input_secrets"></a> [secrets](#input\_secrets) | Hash of name/SecretsManagerARN pairs to include in the task definition as environment variables | <pre>list(object({<br/>    name      = string<br/>    valueFrom = string<br/>  }))</pre> | `[]` | no |
| <a name="input_security_groups"></a> [security\_groups](#input\_security\_groups) | The security groups to attach to the ecs. e.g. ["sg-edcd9784","sg-edcd9785"] | `list(string)` | `[]` | no |
| <a name="input_sidecar_containers"></a> [sidecar\_containers](#input\_sidecar\_containers) | List of sidecar containers | `list(any)` | `[]` | no |
| <a name="input_stop_timeout"></a> [stop\_timeout](#input\_stop\_timeout) | Time duration (in seconds) to wait before the container is forcefully killed if it doesn't exit normally on its own. On Fargate the maximum value is 120 seconds. | `number` | `30` | no |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | A list of subnets to associate with the ecs . e.g. ['subnet-1a2b3c4d','subnet-1a2b3c4e','subnet-1a2b3c4f'] | `list(string)` | n/a | yes |
| <a name="input_systemControls"></a> [systemControls](#input\_systemControls) | System controls to include in the task definition | <pre>list(object({<br/>    namespace = string<br/>    value     = string<br/>  }))</pre> | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |
| <a name="input_target_group_arn"></a> [target\_group\_arn](#input\_target\_group\_arn) | ALB target group ARN. Required when blue\_green = true, leave empty for standard rolling deployment. | `string` | `""` | no |
| <a name="input_task_container_command"></a> [task\_container\_command](#input\_task\_container\_command) | The command that is passed to the container. | `list(string)` | `[]` | no |
| <a name="input_task_container_port"></a> [task\_container\_port](#input\_task\_container\_port) | Port that the container exposes. | `number` | `0` | no |
| <a name="input_task_container_port_mappings"></a> [task\_container\_port\_mappings](#input\_task\_container\_port\_mappings) | List of port objects that the container exposes in addition to the task\_container\_port. | <pre>list(object({<br/>    containerPort = number<br/>    hostPort      = number<br/>    protocol      = string<br/>  }))</pre> | `[]` | no |
| <a name="input_task_execution_role_inline_policy"></a> [task\_execution\_role\_inline\_policy](#input\_task\_execution\_role\_inline\_policy) | Inline IAM policy to associate with the ECS task execution role | `string` | `""` | no |
| <a name="input_task_log_group_name"></a> [task\_log\_group\_name](#input\_task\_log\_group\_name) | The name of the provided CloudWatch Logs log group to use for ECS task logs. | `string` | `""` | no |
| <a name="input_task_log_multiline_pattern"></a> [task\_log\_multiline\_pattern](#input\_task\_log\_multiline\_pattern) | Optional regular expression. Log messages will consist of a line that matches expression and any following lines that don't | `string` | `""` | no |
| <a name="input_task_role_inline_policy"></a> [task\_role\_inline\_policy](#input\_task\_role\_inline\_policy) | Inline IAM policy to associate with the ECS task role | `string` | `""` | no |
| <a name="input_task_secret_tag_key"></a> [task\_secret\_tag\_key](#input\_task\_secret\_tag\_key) | AWS tag key for Secrets Manager secrets the ECS task can read | `string` | `"ucop:application"` | no |
| <a name="input_task_secret_tag_value"></a> [task\_secret\_tag\_value](#input\_task\_secret\_tag\_value) | AWS tag value for Secrets Manager secrets the ECS task can read | `string` | `""` | no |
| <a name="input_volumes"></a> [volumes](#input\_volumes) | List of volume | `list(any)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_arn"></a> [cluster\_arn](#output\_cluster\_arn) | The ARN of the created ECS cluster. |
| <a name="output_cluster_id"></a> [cluster\_id](#output\_cluster\_id) | The ID of the created ECS cluster. |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | The name of the created ECS cluster. |
| <a name="output_ecs_service_name"></a> [ecs\_service\_name](#output\_ecs\_service\_name) | The name of the service. |
| <a name="output_execution_role_arn"></a> [execution\_role\_arn](#output\_execution\_role\_arn) | ARN of IAM role |
| <a name="output_family"></a> [family](#output\_family) | The family of your task definition, used as the definition name |
| <a name="output_revision"></a> [revision](#output\_revision) | The revision of the task in a particular family |
| <a name="output_task_role_arn"></a> [task\_role\_arn](#output\_task\_role\_arn) | ARN of IAM role |
