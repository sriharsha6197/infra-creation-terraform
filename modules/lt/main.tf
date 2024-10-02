resource "aws_security_group" "allow_tls" {
  name        = "${var.env}-lt-sec-grp-${var.component}"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.env}-lt-sec-grp"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = var.sg_ingress_cidr
  from_port         = var.app_port
  ip_protocol       = "tcp"
  to_port           = var.app_port
}
resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4_ssh" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = var.terraform_controller_instance
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_launch_template" "foo" {
  name = "${var.env}-${var.component}"
  image_id = data.aws_ami.example.id
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.allow_tls.id]
  user_data = base64encode(templatefile("${path.module}/userdata.sh",{
    role_name = var.component
  }))
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.env}-lt-${var.component}"
    }
  }
}

resource "aws_autoscaling_group" "bar" {
  name = "${var.env}-asg-${var.component}"
  desired_capacity   = 1
  max_size           = 1
  min_size           = 1
  vpc_zone_identifier = var.subnets
  launch_template {
    id      = aws_launch_template.foo.id
    version = "$Latest"
  }
}