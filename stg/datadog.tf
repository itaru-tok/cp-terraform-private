# MEMO: Datadog コース終了後のコスト削減のためコメントアウト。
# AWS のメトリクス連携を停止することで Datadog の課金対象から外す。
# module "datadog_aws_integration" {
#   source         = "../modules/datadog/aws_integration"
#   aws_account_id = local.account_id
# }

# MEMO: Datadog SLO / Monitor は Free プラン移行とともに機能停止するため
# Terraform 管理から外す。Datadog UI 上のリソースは残るが課金には影響しない。
# module "datadog_slo" {
#   source = "../modules/datadog/slo"
#   env    = local.env
# }
#
# module "datadog_monitor" {
#   source                                   = "../modules/datadog/monitor"
#   env                                      = local.env
#   slo_id_cost_provider_server_availability = module.datadog_slo.id_cost_provider_server_availability
#   apm_view_url_cost_provider               = local.datadog_apm_view_url_cost_provider
# }
