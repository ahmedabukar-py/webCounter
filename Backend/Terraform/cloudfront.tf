
locals {
  s3_origin_id = "S3-${aws_s3_bucket.website_bucket.id}"
}

resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.website_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}
resource "aws_cloudfront_distribution" "s3_distribution" {
  enabled = true
  origin {
    domain_name = aws_s3_bucket_website_configuration.website.website_endpoint
    #domain_name = aws_s3_bucket.website_bucket.bucket_regional_domain_name
    #domain_name = aws_s3_bucket.website_bucket.website_endpoint
    #domain_name = "http://${var.bucket_name}.s3-website-${var.region}.amazonaws.com"

    origin_id = local.s3_origin_id

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"                     # S3 website endpoint only supports HTTP
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"] # Required SSL protocols field

    }
    /*
    s3_origin_config {g
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
 */
  }


  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.cert.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  aliases = ["www.${var.domain_name}"]

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  default_cache_behavior {
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = local.s3_origin_id

    forwarded_values {
      query_string = true
      cookies {
        forward = "none"
      }
    }
  }

  depends_on = [aws_acm_certificate_validation.cert]

  provisioner "local-exec" {
    command = "aws cloudfront create-invalidation --distribution-id ${self.id} --paths '/*'"
  }


}

resource "aws_acm_certificate" "cert" {
  domain_name               = "www.${var.domain_name}"
  validation_method         = "DNS"
  subject_alternative_names = ["www.${var.domain_name}"]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
    if dvo.domain_name == "www.${var.domain_name}"

  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = var.zone_id
}

resource "aws_acm_certificate_validation" "cert" {
  certificate_arn = aws_acm_certificate.cert.arn
  validation_record_fqdns = [
    for dvo in aws_route53_record.cert_validation : dvo.fqdn
  ]
}