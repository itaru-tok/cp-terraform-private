terraform {
  required_version = "~> 1.14.1" // 1.14.1 以上 1.15.0 未満 を許容

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.5.0" // 6.5.0 以上 6.6.0 未満 を許容
    }
  }
}

provider "aws" {
  region  = "ap-northeast-1"
  profile = "cp-terraform-prd"

  default_tags {
    tags = {
      Env = "prd"
    }
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "cp-terraform-prd"
  alias   = "us_east_1"

  default_tags {
    tags = {
      Env = "prd"
    }
  }
}
