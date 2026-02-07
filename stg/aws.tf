module "vpc" {
  source = "../modules/aws/vpc"
  env    = "stg"
}
