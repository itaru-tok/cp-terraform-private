resource "datadog_monitor" "cost_provider_server_latency" {
  name                = "[cost-provider-${var.env}] server-latency"
  type                = "query alert"
  include_tags        = false
  on_missing_data     = "default"
  require_full_window = false
  monitor_thresholds {
    critical = 0.5
    warning  = 0.3
  }
  priority = 2
  query    = <<EOT
avg(last_5m):p95:trace.grpc.client{peer.service:cost-provider, env:${var.env}} > 0.5
EOT
  message  = <<EOT
🚨 gRPCサーバのレイテンシが増加しています。
ただちに[APMのビュー](${var.apm_view_url_cost_provider})を確認してください！
EOT
}

resource "datadog_monitor" "cost_provider_server_error" {
  name                   = "[cost-provider-${var.env}] server-error"
  type                   = "log alert"
  enable_logs_sample     = true
  groupby_simple_monitor = false
  include_tags           = false
  on_missing_data        = "default"
  require_full_window    = false
  monitor_thresholds {
    critical = 5
  }
  priority = 2
  query    = <<EOT
logs("@env:${var.env} @service:cost-provider @level:ERROR").index("*").rollup("count").last("5m") > 5
EOT
  message  = <<EOT
🚨ERRORレベルのログが増加しています。
ただちに、「View in Log Explorer」より調査をしてください！
EOT
}

resource "datadog_monitor" "cost_provider_server_availability_short_burn_rate" {
  name                = "[cost-provider-${var.env}] server-availability-short-burn-rate"
  type                = "slo alert"
  require_full_window = false
  monitor_thresholds {
    critical = 14.4
  }
  query   = <<EOT
burn_rate("${var.slo_id_cost_provider_server_availability}").over("30d").long_window("1h").short_window("5m") > 14.4
EOT
  message = <<EOT
🚨 エラーバジェットの消費が1時間の範囲で加速しています！
EOT
}

resource "datadog_monitor" "cost_provider_server_availability_medium_burn_rate" {
  name                = "[cost-provider-${var.env}] server-availability-medium-burn-rate"
  type                = "slo alert"
  require_full_window = false
  monitor_thresholds {
    critical = 6
  }
  query   = <<EOT
burn_rate("${var.slo_id_cost_provider_server_availability}").over("30d").long_window("6h").short_window("30m") > 6
EOT
  message = <<EOT
🚨 エラーバジェットの消費が6時間の範囲で加速しています！
EOT
}

resource "datadog_monitor" "cost_provider_server_availability_composite_burn_rate" {
  name                = "[cost-provider-${var.env}] server-availability-composite-burn-rate"
  type                = "composite"
  include_tags        = false
  require_full_window = false
  priority            = 2
  query               = <<EOT
${datadog_monitor.cost_provider_server_availability_short_burn_rate.id} || ${datadog_monitor.cost_provider_server_availability_medium_burn_rate.id}
EOT
  message             = <<EOT
🚨 エラーバジェットの消費量が増加しています！
ただちに[APMのビュー](${var.apm_view_url_cost_provider})を確認してください！

- 1時間のバーンレート: {{a.value}} (閾値: 14.4)
- 6時間のバーンレート: {{b.value}} (閾値: 6)
EOT
}
