
  
module "ecs"{
    source = "../ecs"
    name = join("-", [var.name, "ecs"])
    tags = merge(var.tags, map("Name", var.name))
}


module "ecs_task_def" {
    source = "../ecs-task-services"
    name = var.name
    containerport = var.containerport
    hostport = var.hostport
    memory  = var.memory
    cpu     =var.cpu
    image = var.image
    #execution_role_arn = module.ecs.execution_role_arn
    execution_role_arn = module.ecs.execution_role_arn
    cluster = module.ecs.cluster_arn
    cluster_name = module.ecs.cluster_name
    target_group_arn = var.target_group_arn
    subnets = var.subnets
    desired_count = var.desired_count
    deployment_maximum_percent = var.deployment_maximum_percent
    deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent
    assign_public_ip = var.assign_public_ip
    security_groups = var.security_groups
    #depends_on = module.alb.http_tcp_listener_arns
    #depends_on = [module.alb.target_group_arns]
    
}


  
