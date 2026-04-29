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
