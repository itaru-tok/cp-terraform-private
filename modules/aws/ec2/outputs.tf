output "id_nat_1a" {
  value = aws_instance.nat_1a.id
}

output "network_interface_id_nat_1a" {
  value = aws_instance.nat_1a.primary_network_interface_id
}

output "id_bastion" {
  value = aws_instance.bastion.id
}
