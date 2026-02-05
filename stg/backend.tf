terraform {
  backend "s3" {
    bucket = "cp-terraform-itaru-stg"
    key    = "main.tfstate"
    region = "ap-northeast-1"
  }
}
