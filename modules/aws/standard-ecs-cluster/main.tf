module "ecs"{
    source = "../ecs"
    name = join("-", [var.name, "ecs"])
    tags = merge(var.tags, map("Name", var.name))

}

