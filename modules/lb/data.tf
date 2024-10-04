data "aws_route53_zone" "selected" {
  name         = "sriharsha.cloudns.ch"
  private_zone = false
}
