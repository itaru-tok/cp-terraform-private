resource "aws_instance" "nat_1a" {
  ami                         = var.nat_1a.ami_id
  instance_type               = "t2.micro"
  subnet_id                   = var.public_subnet_id
  vpc_security_group_ids      = [var.nat_1a.security_group_id]
  iam_instance_profile        = var.nat_1a.iam_instance_profile
  private_ip                  = "10.0.18.240"
  source_dest_check           = false
  associate_public_ip_address = true

  tags = {
    Name = "cp-nat-1a-${var.env}"
  }
}

resource "aws_instance" "bastion" {
  ami                         = var.bastion.ami_id
  instance_type               = "t2.micro"
  subnet_id                   = var.public_subnet_id
  vpc_security_group_ids      = [var.bastion.security_group_id]
  iam_instance_profile        = var.bastion.iam_instance_profile
  private_ip                  = "10.0.58.15"
  associate_public_ip_address = true

  tags = {
    Name = "cp-bastion-${var.env}"
  }
}
