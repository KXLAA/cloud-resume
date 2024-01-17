data "aws_route53_zone" "main" {
  name         = var.website_domain_name
  private_zone = false
}

resource "aws_route53_record" "root_a" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = var.website_domain_name
  type    = "A"

  alias {
    name                   = aws_s3_bucket_website_configuration.main_s3_bucket_website.website_domain
    zone_id                = aws_s3_bucket.main_s3_bucket.hosted_zone_id
    evaluate_target_health = false
  }

}

resource "aws_route53_record" "www_a" {
  allow_overwrite = true
  zone_id         = data.aws_route53_zone.main.zone_id
  name            = "www.${var.website_domain_name}"
  type            = "A"


  alias {
    name                   = aws_s3_bucket_website_configuration.redirect_s3_bucket_website.website_domain
    zone_id                = aws_s3_bucket.redirect_s3_bucket.hosted_zone_id
    evaluate_target_health = false
  }

}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.ssl_certificate.domain_validation_options : dvo.domain_name => {
      name    = dvo.resource_record_name
      record  = dvo.resource_record_value
      type    = dvo.resource_record_type
      zone_id = data.aws_route53_zone.main.zone_id
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = each.value.zone_id
}
