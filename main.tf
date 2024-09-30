module "vpc" {
  source = "./modules/vpc"
  env = var.env
  vpc_cidr = var.vpc_cidr
  public_subnets = var.public_subnets
  azs = var.azs
  private_subnets = var.private_subnets
  private_azs = var.private_azs
}