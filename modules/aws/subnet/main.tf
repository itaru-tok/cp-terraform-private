resource "aws_subnet" "public_1c" {
  vpc_id                  = var.vpc_id
  cidr_block              = "10.0.64.0/18"
  availability_zone       = "ap-northeast-1c"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-1c-${var.env}"
  }
}

resource "aws_subnet" "public_1a" {
  vpc_id                  = var.vpc_id
  cidr_block              = "10.0.0.0/18"
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-1a-${var.env}"
  }
}

resource "aws_subnet" "private_1c" {
  vpc_id                  = var.vpc_id
  cidr_block              = "10.0.192.0/18"
  availability_zone       = "ap-northeast-1c"
  map_public_ip_on_launch = false
  tags = {
    Name = "private-subnet-1c-${var.env}"
  }
}

resource "aws_subnet" "private_1a" {
  vpc_id                  = var.vpc_id
  cidr_block              = "10.0.128.0/18"
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = false
  tags = {
    Name = "private-subnet-1a-${var.env}"
  }
}
