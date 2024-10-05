resource "aws_security_group" "allow_tls" {
  name        = "${var.env}-lb-sec-grp-${var.alb_type}"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.env}-lb-sec-grp-${var.alb_type}"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  for_each = var.from_port
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = var.sg_ingress_cidr
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
  name               = "${var.env}-${var.alb_type}-lb-${var.component}"
  internal           = var.internal
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_tls.id]
  subnets            = var.subnets

  tags = {
    Environment = "${var.env}-${var.alb_type}-lb"
  }
}

resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = var.dns_name
  type    = "CNAME"
  ttl     = 300
  records = [aws_lb.test.dns_name]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.test.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = var.tg_arn
  }
}

resource "aws_lb_listener" "https" {
  count = var.alb_type == "public" ? 1 :0
  load_balancer_arn = aws_lb.test.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "arn:aws:acm:us-east-1:913524933378:certificate/c69bb7af-6788-449e-8951-d23b155927e9"

  default_action {
    type             = "forward"
    target_group_arn = var.tg_arn
  }
}