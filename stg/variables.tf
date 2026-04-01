locals {
  env                               = "stg"
  account_id                        = "424848769759"
  region                            = "ap-northeast-1"
  base_host                         = "stg.itaru.uk"
  ses_mail_from_domain              = "mail.stg.itaru.uk"
  amplify_domain_name_slack_metrics = "develop.d15icriq5um5ws.amplifyapp.com"

  # EKS Pod Identity: クラスター名は EKS コンソールの一覧と一致させる（cloud-pratica-terraform の EKS は cloud-pratica-${env}）
  eks_cluster_name = "cloud-pratica-stg"
}
