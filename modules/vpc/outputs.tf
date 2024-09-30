output "vpc_id" {
  value = aws_vpc.main.id 
}
output "PB_SUBNETs" {
  value = values(aws_subnet.public_subnet)[*].id
}
output "PVT-SUBNETs" {
 value = values(aws_subnet.private_subnet)[*].id 
}