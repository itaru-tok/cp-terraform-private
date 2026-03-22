# 既存のモジュール
module "service_account" {
  source  = "../modules/gcp/service_account"
  project = local.project
  env     = local.env
}

module "secret_manager" {
  source  = "../modules/gcp/secret_manager"
  project = local.project
  env     = local.env
}

// MEMO: 次チャプターの Cloud Build 自動デプロイでは GCLB を使わない。月額約3000円のコスト削減のため削除。
# module "gclb" {
#   source  = "../modules/gcp/gclb"
#   project = local.project
#   env     = local.env
# }

module "cloud_dns" {
  source  = "../modules/gcp/cloud_dns_unit"
  project = local.project
  env     = local.env
}

module "certificate_manager" {
  source  = "../modules/gcp/certificate_manager_unit"
  project = local.project
  env     = local.env
}

module "certificate_map" {
  source  = "../modules/gcp/certificate_map_unit"
  project = local.project
  env     = local.env
}

module "cloud_run" {
  source  = "../modules/gcp/cloud_run"
  project = local.project
  env     = local.env
}

module "cloud_scheduler" {
  source  = "../modules/gcp/cloud_scheduler"
  project = local.project
  env     = local.env
}

module "cloud_tasks" {
  source  = "../modules/gcp/cloud_tasks"
  project = local.project
  env     = local.env
}

// MEMO: コスト削減のため削除
# module "cloud_armor" {
#   source  = "../modules/gcp/cloud_armor"
#   env     = local.env
#   project = local.project
#   cloud_pratica_backend = {
#     block_ip_ranges = [
#       "114.69.148.224/32" // kanai wifi
#     ]
#   }
# }
