locals {
  env                               = "prd"
  account_id                        = "302222526902"
  region                            = "ap-northeast-1"
  base_host                         = "itaru.uk"
  ses_mail_from_domain              = "mail.${local.base_host}"
  amplify_domain_name_slack_metrics = "main.d2ayxs86edgfeg.amplifyapp.com"
}
