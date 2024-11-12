/*
data "aws_route53_record" "www" {
  zone_id = var.zone_id  # Replace with your hosted zone ID
  name    = "www.${var.domain_name}"
  type    = "CNAME"
}

data "aws_route53_record" "cert_validation" {
  zone_id = var.zone_id # Replace with your hosted zone ID
  name    = var.cert_validation_name
  type    = "CNAME"
}
*/