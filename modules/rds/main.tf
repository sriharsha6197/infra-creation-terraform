resource "aws_security_group" "main" {
  name        = "${var.env}-rds-sg"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.env}-rds-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.main.id
  cidr_ipv4         = var.sg_ingress_cidr
  from_port         = var.app_port
  ip_protocol       = "tcp"
  to_port           = var.app_port
}
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.main.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_db_subnet_group" "main" {
  name       = "${var.env}-db_subnet_group"
  subnet_ids = var.subnets

  tags = {
    Name = "${var.env}-db_subnet_group"
  }
}

resource "aws_rds_cluster" "default" {
  cluster_identifier      = "${var.env}-rds"
  engine                  = var.engine
  engine_version          = var.engine_version
  db_subnet_group_name = aws_db_subnet_group.main.name
  database_name           = "mydb"
  master_username         = data.aws_ssm_parameter.master_username.value
  master_password         = data.aws_ssm_parameter.master_password.value
  skip_final_snapshot = true
  vpc_security_group_ids = [aws_security_group.main.id]
}

resource "aws_rds_cluster_instance" "cluster_instances" {
  count              = 1
  identifier         = "${var.env}-rds-cluster-identifier-${count.index}"
  cluster_identifier = aws_rds_cluster.default.id
  instance_class     = var.instance_class
  engine             = aws_rds_cluster.default.engine
  engine_version     = aws_rds_cluster.default.engine_version
  apply_immediately = true
}
