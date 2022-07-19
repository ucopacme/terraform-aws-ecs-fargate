module "ecs"{
    source = "../ecs"
    name = join("-", [var.name, "ecs"])
    tags = merge(var.tags, map("Name", var.name))
}

module "ecs-task-def" {
    source = "../ecs-task-def"
    containerport = var.containerport
    hostport = var.hostport
    name     =join("-", [var.name,"task-def"])
    memory  = var.memory
    cpu     =var.cpu
    image = var.image
    #execution_role_arn = module.ecs.execution_role_arn
    execution_role_arn = module.ecs.execution_role_arn
}

module "alb" {
  source = "git::https://git@github.com/ucopacme/terraform-aws-alb-nlb//?ref=v0.0.5"
  name   = var.name
#   enabled            = "true"
#   load_balancer_type = "application"
   vpc_id             = var.vpc_id
   subnets            = var.subnets
   security_groups    = var.security_groups
     target_groups = [
    
    {
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "ip"
   
       health_check = {
        matcher = "/"
      }
     
    },
     
    {
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "ip"
    #   # Add instances to target groups
    },
  ]
   
  
  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
      action_type = "redirect"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    },
  ]

 
}
  
