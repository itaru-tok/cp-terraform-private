resource "datadog_service_level_objective" "cost_provider_server_availability" {
  name             = "[cost-provider-${var.env}] server-availability"
  target_threshold = 99.5
  timeframe        = "30d"
  type             = "metric"

  query {
    denominator = "sum:trace.grpc.server.hits{service:cost-provider, env:${var.env}}.as_count()"
    numerator   = "sum:trace.grpc.server.hits{service:cost-provider, env:${var.env}}.as_count() - sum:trace.grpc.server.errors{service:cost-provider, env:${var.env}}.as_count()"
  }

  thresholds {
    target    = 99.5
    timeframe = "30d"
  }
}
