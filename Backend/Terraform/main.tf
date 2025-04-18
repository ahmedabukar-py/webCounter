# S3 Bucket
resource "aws_s3_bucket" "website_bucket" {
  bucket = var.bucket_name
}

# Website Configuration
resource "aws_s3_bucket_website_configuration" "website_config" {
  bucket = aws_s3_bucket.website_bucket.id

  index_document {
    suffix = var.index_document
  }

  error_document {
    key = var.error_document
  }
}

# Public Access Block
resource "aws_s3_bucket_public_access_block" "allow_public_policy" {
  bucket = aws_s3_bucket.website_bucket.id

  block_public_acls       = true
  block_public_policy     = false
  ignore_public_acls      = true
  restrict_public_buckets = false
}


# Bucket Policy
resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.website_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.website_bucket.arn}/*"
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.allow_public_policy]
}


# Upload frontend files
resource "aws_s3_object" "frontend_objects" {
  for_each     = fileset(var.frontend_directory, "**/*")
  bucket       = aws_s3_bucket.website_bucket.id
  key          = each.value
  source       = "${var.frontend_directory}/${each.value}"
  etag         = filemd5("${var.frontend_directory}/${each.value}")
  content_type = lookup(local.mime_types, regex("\\.[^.]+$", each.value), null)

}

# upload config json to s3 
resource "aws_s3_object" "config_json" {
  bucket       = aws_s3_bucket.website_bucket.id
  key          = "config.json"
  content      = local_file.generate_config.content
  content_type = "application/json"
  etag         = md5(local_file.generate_config.content)
}

# MIME types
locals {
  mime_types = {
    ".html" = "text/html"
    ".js"   = "application/javascript"
    ".css"  = "text/css"
    ".json" = "application/json"
  }
}

resource "aws_route53_record" "www" {
  zone_id = var.zone_id
  name    = "www"
  type    = "CNAME" # Changed from CNAME to A
  ttl     = 300
  records = [aws_cloudfront_distribution.s3_distribution.domain_name]

  depends_on = [aws_cloudfront_distribution.s3_distribution]

  lifecycle {
    prevent_destroy = false
  }
}
