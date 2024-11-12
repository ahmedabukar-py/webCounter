output "bucket_website_endpoint" {
  description = "The website endpoint URL"
  value       = "http://${aws_s3_bucket_website_configuration.website_config.website_endpoint}"
}

output "website_endpoint" {
  description = "The website endpoint URL"
  value       = "http://${aws_route53_record.www.fqdn}"
}