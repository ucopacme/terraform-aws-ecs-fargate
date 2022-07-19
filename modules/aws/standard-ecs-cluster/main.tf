module "ecs"{
    source = "../ecs"
    name = join("-", [var.name, "ecs"])
    tags = merge(var.tags, map("Name", var.name))
}


  


module "ecs_task_def" {
    source = "../ecs-task-def"
    containerport = var.containerport
    hostport = var.hostport
    name     =join("-", [var.name,"task-def"])
    memory  = var.memory
    cpu     =var.cpu
    image = var.image
    #execution_role_arn = module.ecs.execution_role_arn
    execution_role_arn = module.ecs.execution_role_arn
    cluster = module.ecs.cluster_arn
    #target_group_arn = module.alb.target_group_arns[0]
    #depends_on = module.alb.http_tcp_listener_arns
    depends_on = [module.alb]
}

# module "ecs-service" {
 #   source = "../ecs-service"
  #  containerport = var.containerport
   # name     =join("-", [var.name,"ecs-service"])
#}


  
