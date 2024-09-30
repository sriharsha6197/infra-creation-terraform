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
resource "aws_route_table" "pvt_route-tables" {
  for_each = zipmap(range(length(var.private_subnets)),var.private_subnets)
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.example[each.key].id
  }
  tags = {
    Name = "${var.env}-pvt-route-table-${each.key + 1}"
  }
}
resource "aws_route_table_association" "pvt" {
  for_each = zipmap(range(length(var.private_subnets)),var.private_subnets)
  subnet_id      = aws_subnet.private_subnet[each.key].id
  route_table_id = aws_route_table.pvt_route-tables[each.key].id
}
resource "aws_security_group" "allow_tls" {
  name        = "${var.env}-sec-grp"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.env}-sec-grp"
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
resource "aws_vpc_peering_connection" "foo" {
  peer_owner_id = aws_vpc.main.owner_id
  peer_vpc_id   = data.aws_vpc.default.id
  vpc_id        = aws_vpc.main.id
  auto_accept = true
  tags = {
    Name = "Peering connection between ${aws_vpc.main.tags["Name"]} and ${data.aws_vpc.default.tags["Name"]}"
  }
}
resource "aws_route" "route-from-default-rt" {
  route_table_id            = data.aws_vpc.default.main_route_table_id
  destination_cidr_block    = var.vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.foo.id
}
resource "aws_route" "route-from-pvt-rt-tables" {
  for_each = zipmap(range(length(var.private_subnets)),var.private_subnets)
  route_table_id            = aws_route_table.pvt_route-tables[each.key].id
  destination_cidr_block    = data.aws_vpc.default.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.foo.id
}