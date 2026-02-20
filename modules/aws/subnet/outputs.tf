output "id_public_subnet_1a" {
  value = aws_subnet.public_1a.id
}

output "id_public_subnet_1c" {
  value = aws_subnet.public_1c.id
}

output "id_private_subnet_1a" {
  value = aws_subnet.private_1a.id
}

output "id_private_subnet_1c" {
  value = aws_subnet.private_1c.id
}

output "public_subnet_ids" {
  value = [
    aws_subnet.public_1a.id,
    aws_subnet.public_1c.id
  ]
}

output "private_subnet_ids" {
  value = [
    aws_subnet.private_1a.id,
    aws_subnet.private_1c.id
  ]
}
