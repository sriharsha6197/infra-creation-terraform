output "vpc_id" {
  value = aws_vpc.main.id 
}
output "PB_SUBNETs" {
  value = aws_subnet.public_subnet.*.id
}