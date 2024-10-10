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
resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4_ssh" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = var.prometheus_cidr
  from_port         = 9100
  ip_protocol       = "tcp"
  to_port           = 9100
}
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}
resource "aws_iam_role" "test_role" {
  name = "${var.env}-${var.component}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  inline_policy {
    name = "${var.env}-${var.component}-policy"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action   = [
        "ssm:PutParameter",
				"ssm:LabelParameterVersion",
				"ssm:DeleteParameter",
				"ssm:UnlabelParameterVersion",
				"ssm:DescribeParameters",
				"ssm:GetParameterHistory",
				"ssm:DescribeDocumentParameters",
				"ssm:GetParametersByPath",
				"ssm:GetParameters",
				"ssm:GetParameter",
				"ssm:DeleteParameters"
        ],
          Effect   = "Allow"
          Resource = "*"
        },
      ]
    })
  }
  tags = {
    tag-key = "${var.env}-${var.component}-role"
  }
}
resource "aws_iam_instance_profile" "test_profile" {
  name = "${var.env}-${var.component}-iam-instance-profile"
  role = aws_iam_role.test_role.name
}
resource "aws_launch_template" "foo" {
  name = "${var.env}-${var.component}"
  image_id = data.aws_ami.example.id
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.allow_tls.id]
  user_data = base64encode(templatefile("${path.module}/userdata.sh",{
    role_name = var.component
    env = var.env
  }))
  iam_instance_profile {
    name = aws_iam_instance_profile.test_profile.name
  }
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.env}-lt-${var.component}"
    }
  }
  
}

resource "aws_autoscaling_group" "bar" {
  name = "${var.env}-asg-${var.component}"
  desired_capacity   = var.desired_capacity
  max_size           = var.max_size
  min_size           = var.min_size
  vpc_zone_identifier = var.subnets
  target_group_arns = [aws_lb_target_group.main.arn]
  launch_template {
    id      = aws_launch_template.foo.id
    version = "$Latest"
  }
  tag {
    key                 = "project"
    value               = "expense"
    propagate_at_launch = true
  }
}

resource "aws_lb_target_group" "main" {
  name     = "${var.env}-tg-${var.component}"
  port     = var.app_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  deregistration_delay = 30
  health_check {
    enabled = true
    healthy_threshold = 2
    interval = 5
    path = "/health"
    unhealthy_threshold = 2
    port = var.app_port
    timeout = 3
  }
}
