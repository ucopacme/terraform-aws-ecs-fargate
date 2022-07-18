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
    # Create HTTPs listners
    https_listeners = [
      {
        port               = 80
        protocol           = "HTTP"
        # certificate_arn    = "arn:aws:acm:us-west-2:897194160541:certificate/87a248af-588b-4aa4-8463-820febd286b4"
        target_group_index = 0
        # ssl_policy         = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"
      }
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

#   https_listener_rules = [

#       {
#       https_listener_index = 0
#       priority             = 5009

#       actions = [{
#         type        = "forward"
#         target_group_index = 1
      
#       }]

#       conditions = [{
#         host_headers = ["dev.evaluators.transcriptevaluationservice.com"]
#       }]
#     },
     

#     ]

  name = join("-", [local.application, local.environment
  ])
  tags = {
    "ucop:application" = local.application
    "ucop:createdBy"   = local.createdBy
    "ucop:environment" = local.environment
    "ucop:group"       = local.group
    "ucop:source"      = local.source
  }
}
  
