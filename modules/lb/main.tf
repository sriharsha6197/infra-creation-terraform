resource "aws_security_group" "allow_tls" {
  name        = "${var.env}-lb-sec-grp"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.env}-lb-sec-grp"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  for_each = var.from_port
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = each.value
  ip_protocol       = "tcp"
  to_port           = each.value
}
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_lb" "test" {
  name               = "${var.env}-${var.alb_type}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_tls.id]
  subnets            = var.subnets

  tags = {
    Environment = "${var.env}-${var.alb_type}"
  }
}