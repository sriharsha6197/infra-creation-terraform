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
  from_port = var.from_port
  subnets = module.vpc.PVT-SUBNETs
  sg_ingress_cidr = var.vpc_cidr
}