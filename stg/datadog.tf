module "datadog_aws_integration" {
  source         = "../modules/datadog/aws_integration"
  aws_account_id = local.account_id
}

module "datadog_slo" {
  source = "../modules/datadog/slo"
  env    = local.env
}

module "datadog_monitor" {
  source                                   = "../modules/datadog/monitor"
  env                                      = local.env
  slo_id_cost_provider_server_availability = module.datadog_slo.id_cost_provider_server_availability
  apm_view_url_cost_provider               = local.datadog_apm_view_url_cost_provider
}

# NOTE: 既存 SLO (401a8c3442d553fba7cc24df5da43b74) は sli_specification.count を含む新形式で
# datadog provider 3.91 では import 時にパースエラーになる。一旦 import せず、Terraform で
# 新しい SLO を作成し、SLO モニターのクエリは module 経由で新 SLO の ID を参照させる。
# 既存 SLO は apply 後に Datadog UI から手動で削除する想定。
# import {
#   to = module.datadog_slo.datadog_service_level_objective.cost_provider_server_availability
#   id = "401a8c3442d553fba7cc24df5da43b74"
# }

import {
  to = module.datadog_monitor.datadog_monitor.cost_provider_server_error
  id = "12776777"
}

import {
  to = module.datadog_monitor.datadog_monitor.cost_provider_server_latency
  id = "12777033"
}

import {
  to = module.datadog_monitor.datadog_monitor.cost_provider_server_availability_short_burn_rate
  id = "12777538"
}

import {
  to = module.datadog_monitor.datadog_monitor.cost_provider_server_availability_medium_burn_rate
  id = "12777569"
}

import {
  to = module.datadog_monitor.datadog_monitor.cost_provider_server_availability_composite_burn_rate
  id = "12777667"
}
