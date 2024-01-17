
resource "aws_acm_certificate" "ssl_certificate" {
  domain_name       = var.website_domain_name
  validation_method = "DNS"
  subject_alternative_names = [
    "www.${var.website_domain_name}",
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "cert_validation_root_a" {
  certificate_arn         = aws_acm_certificate.ssl_certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]

}
