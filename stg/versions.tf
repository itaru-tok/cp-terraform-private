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

# MEMO: Datadog コース終了後 datadog_keys シークレットを削除したため認証情報なし。
# state からのみ removed する用にプロバイダ自体は宣言を残し、credentials 検証はスキップする。
# 必要になったら secrets_manager で datadog_keys を復活させて元に戻す。
provider "datadog" {
  validate = false
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
