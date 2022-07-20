module "alb" {
  name               = var.name
  source             = "../alb"
  enabled            = "true"
  load_balancer_type = "application"
  vpc_id             = var.vpc_id
  subnets            = var.subnets
  security_groups    = ["sg-032b4eb81e054cc1f"]

  target_groups = [

    {
      backend_protocol = var.backend_protocol
      backend_port     = var.backend_port
      target_type      = "ip"
      vpc_id           = var.vpc_id

    },

    {
      backend_protocol = var.backend_protocol
      backend_port     = var.backend_protocol
      target_type      = "ip"
      vpc_id           = var.vpc_id
      #   # Add instances to target groups
    },
  ]
  # Create HTTPs listners
  # https_listeners = [
  #   {
  #     port     = 80
  #     protocol = "HTTP"
  #     # certificate_arn    = "arn:aws:acm:us-west-2:897194160541:certificate/87a248af-588b-4aa4-8463-820febd286b4"
  #     target_group_index = 0
  #     # ssl_policy         = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"
  #   }
  # ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
      # action_type        = "redirect"
      # redirect = {
      #   port        = "443"
      #   protocol    = "HTTPS"
      #   status_code = "HTTP_301"
      # }
    },
  ]
 tags = var.tags

}
  
  
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
    target_group_arn = module.alb.target_group_arns[0]
    #depends_on = module.alb.http_tcp_listener_arns
    depends_on = [module.alb.target_group_arns]
    
}

# module "ecs-service" {
 #   source = "../ecs-service"
  #  containerport = var.containerport
   # name     =join("-", [var.name,"ecs-service"])
#}


  
