
  
module "ecs"{
    source = "../ecs"
    name = join("-", [var.name, "ecs"])
    tags = merge(var.tags, map("Name", var.name))
}


module "ecs_task_def" {
    source = "../ecs-task-def"
    name = var.name
    containerport = var.containerport
    hostport = var.hostport
    memory  = var.memory
    cpu     =var.cpu
    image = var.image
    #execution_role_arn = module.ecs.execution_role_arn
    execution_role_arn = module.ecs.execution_role_arn
    cluster = module.ecs.cluster_arn
    target_group_arn = var.target_group_arn
    subnets = var.subnets
    #depends_on = module.alb.http_tcp_listener_arns
    #depends_on = [module.alb.target_group_arns]
    
}

# module "ecs-service" {
 #   source = "../ecs-service"
  #  containerport = var.containerport
   # name     =join("-", [var.name,"ecs-service"])
#}


  
