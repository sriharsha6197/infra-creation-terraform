resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr

  tags = {
    Name = "${var.env}-vpc"
  }
}
resource "aws_subnet" "public_subnet" {
  for_each = zipmap(range(length(var.public_subnets)),var.public_subnets)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnets[each.key]
  availability_zone = var.azs[each.key]

  tags = {
    Name = "${var.env}-public-subnet-${each.key}+1"
  }
}