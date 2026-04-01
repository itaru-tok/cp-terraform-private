# GCLB Resources
resource "google_compute_region_network_endpoint_group" "slack_metrics_api" {
  name                  = "slack-metrics-api-${var.env}"
  network_endpoint_type = "SERVERLESS"
  project               = var.project
  region                = "asia-northeast1"
  cloud_run {
    service  = "slack-metrics-api-${var.env}"
  }
}

resource "google_compute_managed_ssl_certificate" "default" {
  name    = "default"
  project = var.project
  type    = "MANAGED"
  managed {
    domains = ["gcp-${var.env}.itaru.uk"]
  }
}

resource "google_compute_url_map" "cloud_pratica" {
  default_service = google_compute_backend_service.slack_metrics_api.self_link
  name            = "cloud-pratica-${var.env}"
  project         = var.project
}

resource "google_compute_backend_service" "slack_metrics_api" {
  enable_cdn            = false
  load_balancing_scheme = "EXTERNAL_MANAGED"
  locality_lb_policy    = "ROUND_ROBIN"
  name                  = "slack-metrics-api-${var.env}"
  port_name             = "http"
  project               = var.project
  protocol              = "HTTPS"
  session_affinity      = "NONE"
  timeout_sec           = 30
  backend {
    balancing_mode = "UTILIZATION"
    group          = google_compute_region_network_endpoint_group.slack_metrics_api.self_link
  }
}

resource "google_compute_target_https_proxy" "cp_https" {
  certificate_map  = "https://certificatemanager.googleapis.com/v1/projects/${var.project}/locations/global/certificateMaps/cloud-pratica-${var.env}"
  name             = "cloud-pratica-${var.env}-target-proxy"
  project          = var.project
  proxy_bind       = false
  quic_override    = "NONE"
  ssl_certificates = [google_compute_managed_ssl_certificate.default.self_link]
  tls_early_data   = "DISABLED"
  url_map          = google_compute_url_map.cloud_pratica.self_link
}

resource "google_compute_global_forwarding_rule" "cp_https" {
  project               = var.project
  name                  = "cp-https-${var.env}"
  ip_protocol           = "TCP"
  ip_version            = "IPV4"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  port_range            = "443-443"
  source_ip_ranges      = []
  target                = google_compute_target_https_proxy.cp_https.self_link
}
