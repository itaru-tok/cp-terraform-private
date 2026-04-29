output "external_id" {
  value = datadog_integration_aws_account.datadog_integration.auth_config.aws_auth_config_role.external_id
}

output "permission_chunks" {
  value = local.permission_chunks
}
