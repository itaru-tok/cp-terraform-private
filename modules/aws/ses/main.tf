resource "aws_sesv2_email_identity" "domain" {
  email_identity = var.domain
}

resource "aws_sesv2_email_identity_mail_from_attributes" "domain" {
  email_identity         = aws_sesv2_email_identity.domain.email_identity
  mail_from_domain       = var.mail_from_domain
  behavior_on_mx_failure = var.behavior_on_mx_failure
}
