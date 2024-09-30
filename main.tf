module "vpc" {
  source = "./modules/vpc"
  env = var.env
  vpc_cidr = var.vpc_cidr
  public_subnets = var.public_subnets
  azs = var.azs
  private_subnets = var.private_subnets
  private_azs = var.private_azs
  from_port = var.from_port
}
module "public" {
  source = "./modules/lb"
  env = var.env
  alb_type = "public"
  internal = false
  sg_ingress_cidr = "0.0.0.0/0"
  vpc_id = module.vpc.vpc_id
  from_port = var.from_port
  subnets = module.vpc.PB_SUBNETs
}
module "private" {
  source = "./modules/lb"
  env = var.env
  alb_type = "private"
  vpc_id = module.vpc.vpc_id
  internal = true
  from_port = var.from_port
  subnets = module.vpc.PVT-SUBNETs
  sg_ingress_cidr = var.vpc_cidr
}
module "frontend" {
  source = "./modules/lt"
  env = var.env
  component = "frontend"
  sg_ingress_cidr = var.vpc_cidr
  from_port = var.from_port
  instance_type = var.instance_type
  vpc_id = module.vpc.vpc_id
  subnets = module.vpc.PVT-SUBNETs
}
module "backend" {
  source = "./modules/lt"
  env = var.env
  component = "backend"
  sg_ingress_cidr = var.vpc_cidr
  from_port = 8080
  instance_type = var.instance_type
  vpc_id = module.vpc.vpc_id
  subnets = module.vpc.PVT-SUBNETs
}
