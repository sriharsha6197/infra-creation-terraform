env = "dev"
vpc_cidr = "10.40.0.0/16"
public_subnets = ["10.40.1.0/24","10.40.2.0/24"]
private_subnets = ["10.40.3.0/24","10.40.4.0/24"]
azs = ["us-east-1a","us-east-1b"]
from_port = [443,80,22]
alb_type = ""
subnets = ""
vpc_id = ""
sg_ingress_cidr = ""
internal = ""
component = ""
instance_type = "t3.micro"
app_port = ""
terraform_controller_instance = "172.31.26.181/32"
engine="aurora-mysql"
engine_version="5.7.mysql_aurora.2.11.3"
instance_class = "db.t3.medium"
dns_name=""
tg_arn = ""
desired_capacity = 1
max_size = 1
min_size = 1
prometheus_cidr = ""