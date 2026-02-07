resource "aws_vpc" "cloud_pratica_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "cloud-pratica-${var.env}"
  }
}
