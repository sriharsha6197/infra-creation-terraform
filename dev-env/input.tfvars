env = "dev"
vpc_cidr = "10.40.0.0/16"
public_subnets = ["10.40.1.0/24","10.40.2.0/24"]
private_subnets = ["10.40.3.0/24","10.40.4.0/24"]
azs = ["us-east-1a","us-east-1b"]
private_azs = ["us-east-1c","us-east-1d"]
from_port = [443,80,22]