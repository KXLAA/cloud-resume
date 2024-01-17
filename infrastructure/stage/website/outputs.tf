
output "aws_route53_zone" {
  value       = data.aws_route53_zone.main.zone_id
  description = "The ID of the Route53 zone"
}


output "main-s3-endpoint" {
  value       = aws_s3_bucket_website_configuration.main_s3_bucket_website.website_domain
  description = "The endpoint of the S3 bucket"
}

output "redirect_s3_bucket" {
  value       = aws_s3_bucket_website_configuration.redirect_s3_bucket_website.website_domain
  description = "The endpoint of the S3 bucket"
}

output "main-s3-hosted_zone_id" {
  value       = aws_s3_bucket.main_s3_bucket.hosted_zone_id
  description = "The Route53 Hosted Zone ID for this bucket's region"
}

output "redirect-s3-hosted_zone_id" {
  value       = aws_s3_bucket.redirect_s3_bucket.hosted_zone_id
  description = "The Route53 Hosted Zone ID for this bucket's region"
}


output "website_url" {
  description = "The URL of the website (main bucket)"
  value       = aws_cloudfront_distribution.main_s3_bucket_distribution.domain_name
}

output "redirect_url" {
  description = "The URL of the website (redirect bucket)"
  value       = aws_cloudfront_distribution.redirect_s3_bucket_distribution.domain_name
}

