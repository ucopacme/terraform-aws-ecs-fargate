module "ecs"{
    source = "../ecs"
    name = join("-", [var.name, "ecs"])
    tags = merge(var.tags, map("Name", var.name))

}

module "ecs-task-def" {
    source = "../ecs-task-def"
    name = join("-", [var.name, "ecs-task-def"])
    containerport = 80
    hostport = 80
}
