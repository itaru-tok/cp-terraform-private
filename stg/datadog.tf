module "datadog_aws_integration" {
  source         = "../modules/datadog/aws_integration"
  aws_account_id = local.account_id
}
