data "aws_route53_zone" "selected" {
  name         = "harsha.shop"
  private_zone = false
}
