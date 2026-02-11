resource "aws_instance" "nat_1a" {
  ami                         = "ami-03d1820163e6b9f5d"
  instance_type               = "t2.micro"
  subnet_id                   = var.public_subnet_1a_id
  vpc_security_group_ids      = [var.sg_nat_id]
  iam_instance_profile        = "cp-nat-stg"
  private_ip                  = "10.0.18.240"
  source_dest_check           = false
  associate_public_ip_address = false

  tags = {
    Name = "cp-nat-1a-${var.env}"
  }
}

resource "aws_instance" "bastion" {
  ami                         = "ami-03d1820163e6b9f5d"
  instance_type               = "t2.micro"
  subnet_id                   = var.public_subnet_1a_id
  vpc_security_group_ids      = [var.sg_bastion_id]
  iam_instance_profile        = "cp-bastion-stg"
  private_ip                  = "10.0.58.15"
  associate_public_ip_address = false

  tags = {
    Name = "cp-bastion-${var.env}"
  }
}
