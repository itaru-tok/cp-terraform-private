resource "aws_route_table" "public_rt" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.gateway_id
  }
  tags = {
    Name = "cp-rtb-public-${var.env}"
  }
}

resource "aws_route_table_association" "public_subnet" {
  for_each       = toset(var.public_subnet_ids)
  route_table_id = aws_route_table.public_rt.id
  subnet_id      = each.value
}
