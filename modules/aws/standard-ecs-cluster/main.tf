module "ecs"{
    source = "../ecs"
    name = join("-", [var.name, "ecs"])
    tags = merge(var.tags, map("Name", var.name))
}

module "ecs-task-def" {
    source = "../ecs-task-def"
    containerport = 80
    hostport = 80
    image = var.image
    #execution_role_arn = module.ecs.execution_role_arn
    execution_role_arn = "arn:aws:iam::944706592399:role/ecs-kk-test-ecs_ecsTaskExecutionRole"
}

