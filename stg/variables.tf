locals {
  env                  = "stg"
  account_id           = "424848769759"
  region               = "ap-northeast-1"
  base_host            = "stg.itaru.uk"
  ses_mail_from_domain = "mail.stg.itaru.uk"
  public_subnet_ids = [
    module.subnet.id_public_subnet_1a,
    module.subnet.id_public_subnet_1c
  ]
  private_subnet_ids = [
    module.subnet.id_private_subnet_1a,
    module.subnet.id_private_subnet_1c
  ]
}
