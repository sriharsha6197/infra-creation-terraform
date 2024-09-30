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
    Name = "${var.env}-public-subnet-${each.key + 1}"
  }
}
resource "aws_subnet" "private_subnet" {
  for_each = zipmap(range(length(var.private_subnets)),var.private_subnets)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnets[each.key]
  availability_zone = var.private_azs[each.key]

  tags = {
    Name = "${var.env}-private-subnet-${each.key + 1}"
  }
}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.env}-igw"
  }
}
resource "aws_route_table" "pb_route-tables" {
  for_each = zipmap(range(length(var.public_subnets)),var.public_subnets)
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "${var.env}-pb-route-table-${each.key + 1}"
  }
}
resource "aws_route_table_association" "a" {
  for_each = zipmap(range(length(var.public_subnets)),var.public_subnets)
  subnet_id      = aws_subnet.public_subnet[each.key].id
  route_table_id = aws_route_table.pb_route-tables[each.key].id
}
resource "aws_eip" "eip" {
  for_each = zipmap(range(length(var.private_subnets)),var.private_subnets)
  domain   = "vpc"
  tags = {
    Name = "${var.env}-eip-${each.key+1}"
  }
}
resource "aws_nat_gateway" "example" {
  for_each = zipmap(range(length(var.private_subnets)),var.private_subnets)
  allocation_id = aws_eip.eip[each.key].id
  subnet_id     = aws_subnet.public_subnet[each.key].id

  tags = {
    Name = "${var.env}-ngw-${each.key+1}"
  }
}