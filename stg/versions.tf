terraform {
  required_version = "~> 1.14.1" // 1.14.1 以上 1.15.0 未満 を許容

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.5.0" // 6.5.0 以上 6.6.0 未満 を許容
    }
    datadog = {
      source  = "DataDog/datadog"
      version = "~> 3.0"
    }
  }
}

provider "datadog" {
  api_key = local.datadog_keys.api_key
  app_key = local.datadog_keys.app_key
  api_url = "https://api.ap1.datadoghq.com"
}

provider "aws" {
  region  = "ap-northeast-1"
  profile = "cp-terraform-stg"

  default_tags {
    tags = {
      Env = "stg"
    }
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "cp-terraform-stg"
  alias   = "us_east_1"

  default_tags {
    tags = {
      Env = "stg"
    }
  }
}
