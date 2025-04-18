output "bucket_website_endpoint" {
  description = "The website endpoint URL"
  value       = "http://${aws_s3_bucket_website_configuration.website_config.website_endpoint}"
}

output "website_endpoint" {
  description = "The website endpoint URL"
  value       = "http://${aws_route53_record.www.fqdn}"
}

output "api_gateway_url" {
  value = "${aws_api_gateway_stage.dev.invoke_url}/visitor-count"
}

/*
resource "local_file" "frontend_config" {
  content = jsonencode({
    apiUrl = "${aws_api_gateway_stage.dev.invoke_url}/visitor-count"
  })
  filename = "/Users/ahmedabdirahman/Documents/TerraformConfig/webCounter/frontend/config.json"  # adjust path to match your project layout
}
*/

resource "local_file" "generate_config" {
  content = jsonencode({
  apiUrl = "${aws_api_gateway_stage.dev.invoke_url}/visitor-count" })
  filename = var.frontend_path
}


