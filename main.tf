# Website S3 Bucket
resource "aws_s3_bucket" "web_01" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_versioning" "web_01_versioning" {
  bucket = aws_s3_bucket.web_01.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_website_configuration" "web_01_config" {
  bucket = aws_s3_bucket.web_01.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_public_access_block" "web_01_pub" {
  bucket = aws_s3_bucket.web_01.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# CloudFront Origin Access Control
resource "aws_cloudfront_origin_access_control" "web_01_oac" {
  name                              = "${var.bucket_name}-oac"
  description                       = "OAC for ${var.bucket_name}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# CloudFront Distribution with default HTTPS
resource "aws_cloudfront_distribution" "web_01_distr" {
  origin {
    domain_name              = aws_s3_bucket.web_01.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.web_01_oac.id
    origin_id                = "S3-${var.bucket_name}"
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Static website distribution"
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${var.bucket_name}"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}

# S3 Bucket Policy for CloudFront Access
resource "aws_s3_bucket_policy" "website_bucket_policy_oac" {
  bucket = aws_s3_bucket.web_01.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "cloudfront.amazonaws.com"
        },
        Action   = "s3:GetObject",
        Resource = "${aws_s3_bucket.web_01.arn}/*",
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.web_01_distr.arn
          }
        }
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.web_01_pub]
}

# Upload HTML
resource "aws_s3_object" "web_01_html" {
  bucket       = aws_s3_bucket.web_01.id
  key          = "index.html"
  source       = "index.html"
  content_type = "text/html"
  etag         = filemd5("index.html")
}

# Upload CSS
resource "aws_s3_object" "web_01_css" {
  for_each     = fileset("NextWork - Everyone should be in a job they love_files", "**/*.css")
  bucket       = aws_s3_bucket.web_01.id
  key          = "css/${each.value}"
  source       = "./NextWork - Everyone should be in a job they love_files/${each.value}"
  content_type = "text/css"
  etag         = filemd5("./NextWork - Everyone should be in a job they love_files/${each.value}")
}

# Upload JS
resource "aws_s3_object" "web_01_js" {
  for_each     = fileset("NextWork - Everyone should be in a job they love_files", "**/*.js")
  bucket       = aws_s3_bucket.web_01.id
  key          = "js/${each.value}"
  source       = "./NextWork - Everyone should be in a job they love_files/${each.value}"
  content_type = "application/javascript"
  etag         = filemd5("./NextWork - Everyone should be in a job they love_files/${each.value}")
}

# Upload Images
resource "aws_s3_object" "web_01_imgs" {
  for_each     = fileset("NextWork - Everyone should be in a job they love_files", "**/*.jpg")
  bucket       = aws_s3_bucket.web_01.id
  key          = "img/${each.value}"
  source       = "./NextWork - Everyone should be in a job they love_files/${each.value}"
  content_type = "image/jpeg"
  etag         = filemd5("./NextWork - Everyone should be in a job they love_files/${each.value}")
}

output "cloudfront_domain_name" {
  description = "CloudFront distribution domain name"
  value       = aws_cloudfront_distribution.web_01_distr.domain_name
}
