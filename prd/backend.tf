terraform {
  backend "s3" {
    bucket = "cp-terraform-itaru-prd"
    key    = "main.tfstate"
    region = "ap-northeast-1"
  }
}
