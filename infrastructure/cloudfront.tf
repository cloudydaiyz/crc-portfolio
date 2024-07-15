# CloudFront

# Amazon Certificate Manager (ACM) certificate is needed to route HTTPS traffic
# to Cloudflare domain
resource "aws_acm_certificate" "example" {
  provider = aws.us_east_1
  domain_name       = "cloudydaiyz.com"
  validation_method = "DNS"
}

# Use an external data source to retrieve the DNS validation records
data "aws_acm_certificate" "example" {
  provider = aws.us_east_1
  domain = aws_acm_certificate.example.domain_name
  statuses = ["PENDING_VALIDATION"]
}

# OAI purpose: Users can only access bucket through CloudFront, not through S3 URL.
# Can't use this with static website hosting functionality
# https://www.stormit.cloud/blog/cloudfront-origin-access-identity/
resource "aws_cloudfront_origin_access_identity" "example" {
#   provider = aws.default
  provider = aws.us_east_1
  comment = "OAI for CloudFront distribution"
}

# Grants OAI permission to access S3 bucket
resource "aws_s3_bucket_policy" "example" {
  provider = aws.default
  bucket = aws_s3_bucket.crc-bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity ${aws_cloudfront_origin_access_identity.example.iam_arn}"
        }
        Action = "s3:GetObject"
        Resource = "${aws_s3_bucket.crc-bucket.arn}/*"
      }
    ]
  })
}

locals {
  s3_origin_id = "myS3Origin"
}

# CloudFront distribution for the S3 bucket
resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name              = aws_s3_bucket.crc-bucket.bucket_regional_domain_name
    origin_id                = local.s3_origin_id # unique ID for this origin in this resource
    # origin_access_control_id = aws_cloudfront_origin_access_control.default.id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.example.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id # use identifier for the origin
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "CA", "GB", "DE"]
    }
  }

  viewer_certificate {
    acm_certificate_arn            = aws_acm_certificate.example.arn
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = "TLSv1.2_2019"
    cloudfront_default_certificate = false
  }

  aliases = ["cloudydaiyz.com"]
}

# Outputs to help manually add DNS validation records in Cloudflare
output "acm_certificate_dns_validation" {
  value = aws_acm_certificate.example.domain_validation_options
}

# resource "aws_cloudfront_origin_access_control" "default" {
#   provider = aws.us_east_1
#   name                              = "crc-default"
#   description                       = "Example Policy"
#   origin_access_control_origin_type = "s3"
#   signing_behavior                  = "always"
#   signing_protocol                  = "sigv4"
# }