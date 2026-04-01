resource "google_certificate_manager_certificate" "main" {
  location = "global"
  name     = "gcp-${var.env}-itaru-uk-global"
  project  = var.project
  managed {
    dns_authorizations = ["projects/672056542792/locations/global/dnsAuthorizations/dns-authz-gcp-${var.env}-itaru-uk"]
    domains            = ["*.gcp-${var.env}.itaru.uk"]
  }
}
