locals {
  env        = "stg"
  account_id = "424848769759"
  region     = "ap-northeast-1"
  public_subnet_ids = [
    module.subnet.id_public_subnet_1a,
    module.subnet.id_public_subnet_1c
  ]
}
