terraform {
  required_version = "~> 1.14.1" // 1.14.1 以上 1.15.0 未満 を許容

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0" // 5.0 以上 6.0 未満 を許容
    }
  }
}

provider "google" {
  project                     = local.project
  impersonate_service_account = "cp-terraform-stg@cp-itaru-stg.iam.gserviceaccount.com"
}
