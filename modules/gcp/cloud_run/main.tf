resource "google_cloud_run_service" "slack_metrics_api" {
  name     = "slack-metrics-api-${var.env}"
  location = "asia-northeast1"
  project  = var.project
  template {
    spec {
      containers {
        image = "placeholder"
      }
    }
  }

  lifecycle {
    ignore_changes = [
      template,
      metadata[0].annotations,
      metadata[0].labels,
      traffic
    ]
  }
}

resource "google_cloud_run_v2_job" "db_migrator" {
  name     = "db-migrator-${var.env}"
  location = "asia-northeast1"
  project  = var.project
  template {
    template {
      max_retries     = 3
      service_account = "db-migrator-stg@${var.project}.iam.gserviceaccount.com"
      timeout         = "600s"

      containers {
        image = "asia-northeast1-docker.pkg.dev/${var.project}/cloud-pratica-stg/db-migrator@sha256:4492389fc55dec2e80bf74240fc053b3b5f41d2dad634d425604380909a02607"

        env {
          name  = "SSL_MODE"
          value = "require"
        }
        env {
          name = "DB_PASSWORD"
          value_source {
            secret_key_ref {
              secret  = "db-migrator-password-stg"
              version = "latest"
            }
          }
        }
        env {
          name = "DB_HOST"
          value_source {
            secret_key_ref {
              secret  = "db-cloud-pratica-host-stg"
              version = "latest"
            }
          }
        }
        env {
          name = "DB_USER"
          value_source {
            secret_key_ref {
              secret  = "db-migrator-user-stg"
              version = "latest"
            }
          }
        }

        resources {
          limits = {
            cpu    = "1000m"
            memory = "512Mi"
          }
        }
      }

      vpc_access {
        egress = "PRIVATE_RANGES_ONLY"
        network_interfaces {
          network    = "cloud-pratica-stg"
          subnetwork = "tokyo-1-stg"
        }
      }
    }
  }

  lifecycle {
    ignore_changes = [
      template,
      annotations,
      labels
    ]
  }
}
