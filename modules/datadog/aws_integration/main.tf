terraform {
  required_providers {
    datadog = {
      source = "DataDog/datadog"
    }
  }
}

data "datadog_integration_aws_iam_permissions" "datadog_permissions" {}

locals {
  all_permissions = data.datadog_integration_aws_iam_permissions.datadog_permissions.iam_permissions

  permission_sizes = [
    for perm in local.all_permissions :
    length(perm) + 3
  ]
  cumulative_sizes = [
    for i in range(length(local.permission_sizes)) :
    sum(slice(local.permission_sizes, 0, i + 1))
  ]
  chunk_assignments = [
    for cumulative_size in local.cumulative_sizes :
    floor(cumulative_size / var.iam_policy_target_chunk_size)
  ]
  chunk_numbers = distinct(local.chunk_assignments)
  permission_chunks = [
    for chunk_num in local.chunk_numbers : [
      for i, perm in local.all_permissions :
      perm if local.chunk_assignments[i] == chunk_num
    ]
  ]
}

resource "datadog_integration_aws_account" "datadog_integration" {
  account_tags   = []
  aws_account_id = var.aws_account_id
  aws_partition  = "aws"

  aws_regions {
    include_all = true
  }

  auth_config {
    aws_auth_config_role {
      role_name = "DatadogIntegrationRole"
    }
  }

  resources_config {
    # コスト削減: Cloud Security 等の追加課金機能を無効化
    cloud_security_posture_management_collection = false
    extended_collection                          = false
  }

  traces_config {
    xray_services {
    }
  }

  logs_config {
    lambda_forwarder {
    }
  }

  metrics_config {
    # コスト削減: 必要な namespace だけ収集
    namespace_filters {
      include_only = var.namespace_filters_include_only
    }
  }
}
