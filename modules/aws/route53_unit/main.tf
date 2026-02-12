resource "aws_route53_zone" "zone" {
  name = var.zone_name
}

resource "aws_route53_record" "record" {
  for_each = { for r in var.records : "${r.name}-${r.type}" => r }

  zone_id = aws_route53_zone.zone.zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = lookup(each.value, "ttl", null)
  records = lookup(each.value, "values", null)

  dynamic "alias" {
    for_each = each.value.alias != null ? [each.value.alias] : []
    content {
      zone_id                = each.value.alias.zone_id
      name                   = each.value.alias.name
      evaluate_target_health = each.value.alias.evaluate_target_health
    }
  }
}

resource "aws_route53_record" "ses_mail_mx" {
  count   = var.ses.enable ? 1 : 0
  zone_id = aws_route53_zone.zone.zone_id
  name    = "mail.${var.zone_name}"
  type    = "MX"
  ttl     = 300
  records = ["10 feedback-smtp.ap-northeast-1.amazonses.com"]
}

resource "aws_route53_record" "ses_mail_txt" {
  count   = var.ses.enable ? 1 : 0
  zone_id = aws_route53_zone.zone.zone_id
  name    = "mail.${var.zone_name}"
  type    = "TXT"
  ttl     = 300
  records = ["v=spf1 include:amazonses.com ~all"]
}

resource "aws_route53_record" "ses_dmarc_txt" {
  count   = var.ses.enable ? 1 : 0
  zone_id = aws_route53_zone.zone.zone_id
  name    = "_dmarc.${var.zone_name}"
  type    = "TXT"
  ttl     = 300
  records = ["v=DMARC1; p=none;"]
}

resource "aws_route53_record" "ses_dkim_cname" {
  count   = var.ses.enable ? 3 : 0
  zone_id = aws_route53_zone.zone.zone_id
  name    = "${element(var.ses.dkim_tokens, count.index)}._domainkey.${var.zone_name}"
  type    = "CNAME"
  ttl     = 1800
  records = ["${element(var.ses.dkim_tokens, count.index)}.dkim.amazonses.com"]
}
