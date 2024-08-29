# Amazon Certificate Manager (ACM) certificate is needed to route HTTPS traffic
# to/from Cloudflare domain since CloudFront distributions w/ CNAME (alternate 
# domain name must be attached to a trusted, valid SSL/TLS certificate that covers 
# the CNAME
# See: https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/CNAMEs.html#alternate-domain-names-requirements
resource "aws_acm_certificate" "example" {
  provider    = aws.us_east_1
  domain_name = "cloudydaiyz.com"

  # From AWS: If the ACM certificate request status is Pending validation, the request 
  # is waiting for action from you. If you chose DNS validation, you must write the CNAME 
  # record that ACM created for you to your DNS database.
  # https://docs.aws.amazon.com/acm/latest/userguide/certificate-validation.html
  validation_method = "DNS"
}

# If you were validating with AWS as your DNS (using Route53 as your DNS), then you
# would need to create a route53 record to validate the domain (create a new CNAME
# with the given domain validation options). I'm using Cloudflare so I don't need 
# to use this.
# resource "aws_route53_record" "example" {
#   zone_id = "Z1234567890"
#   name    = aws_acm_certificate.example.domain_validation_options[0].resource_record_name
#   type    = aws_acm_certificate.example.domain_validation_options[0].resource_record_type
#   ttl     = 60
#   records = [aws_acm_certificate.example.domain_validation_options[0].resource_record_value]
# }

# This waits for certificate validation to complete
resource "aws_acm_certificate_validation" "example" {
  provider        = aws.us_east_1
  certificate_arn = aws_acm_certificate.example.arn
}

# OAI purpose: Users can only access bucket through CloudFront, not through S3 URL.
# NOTE: Deprecated, Amazon recommends switching to OAC: https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/private-content-restricting-access-to-s3.html
# resource "aws_cloudfront_origin_access_identity" "example" {
#   #   provider = aws.default
#   provider = aws.us_east_1
#   comment  = "OAI for CloudFront distribution"
# }

# OAI purpose: Users can only access bucket through CloudFront, not through S3 URL.
resource "aws_cloudfront_origin_access_control" "default" {
  provider                          = aws.kduncan
  name                              = "crc-default"
  description                       = "Example Policy"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# Grants OAI permission to access S3 bucket
resource "aws_s3_bucket_policy" "example" {
  provider = aws.kduncan
  bucket   = aws_s3_bucket.crc-bucket.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": {
      "Sid": "AllowCloudFrontServicePrincipalReadOnly",
      "Effect": "Allow",
      "Principal": {
          "Service": "cloudfront.amazonaws.com"
      },
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::${aws_s3_bucket.crc-bucket.id}/*",
      "Condition": {
          "StringEquals": {
              "AWS:SourceArn": "arn:aws:cloudfront::${local.account_id}:distribution/${aws_cloudfront_distribution.s3_distribution.id}"
          }
      }
  }
}
EOF
}

# CloudFront distribution for the S3 bucket
resource "aws_cloudfront_distribution" "s3_distribution" {
  provider = aws.kduncan
  origin {
    domain_name = aws_s3_bucket.crc-bucket.bucket_regional_domain_name
    origin_id   = local.s3_origin_id # unique ID for this origin in this resource

    # From AWS: Before you create an origin access control (OAC) or set it up in a CloudFront 
    # distribution, make sure the OAC has permission to access the S3 bucket origin. Do this 
    # after creating a CloudFront distribution, but before adding the OAC to the S3 origin in 
    # the distribution configuration.
    # https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/private-content-restricting-access-to-s3.html

    # This means I need to create the CloudFront distribution in one step, then create the 
    # OAC (with permission to access S3 bucket origin) and add it to the distribution in another
    # step (split this into 2 steps).
    origin_access_control_id = aws_cloudfront_origin_access_control.default.id
  }

  enabled             = true
  is_ipv6_enabled     = true

  # Homepage is the root S3 object
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = local.s3_origin_id # use identifier defined earlier for the origin
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
      restriction_type = "none"
      locations        = []
    }
  }

  viewer_certificate {
    # cloudfront_default_certificate = true

    # https://github.com/hashicorp/terraform-provider-aws/issues/34950#issuecomment-2201956351
    cloudfront_default_certificate = false
    acm_certificate_arn      = aws_acm_certificate.example.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  aliases = ["cloudydaiyz.com"]

  # Ensure ACM certificate is valid
  # https://github.com/cloudposse/terraform-aws-cloudfront-s3-cdn/issues/55#issuecomment-711109385
  depends_on = [aws_acm_certificate_validation.example]
}

# DNS validation records to help manually add them in Cloudflare (in case the
# records are needed again in the future)
# https://docs.aws.amazon.com/acm/latest/userguide/certificate-validation.html
#
# UPDATE: This is of useless since this doesn't get displayed until everything's 
# done deploying, and the deployment waits until the DNS is validated to continue 
# deployment (see resource "aws_acm_certificate_validation" "example"). 
# 
# Instead, use:
# terraform console
# > aws_acm_certificate.example.domain_validation_options
# output "acm_certificate_dns_validation" {
#   value = aws_acm_certificate.example.domain_validation_options
# }

# Second option: add DNS validation record in cloudflare
# provider "cloudflare" {
#   email   = "your-email@example.com"
#   api_key = "your-cloudflare-api-key"
# }

# resource "cloudflare_record" "example" {
#   zone_id = "your-cloudflare-zone-id"
#   name    = aws_acm_certificate.example.domain_validation_options[0].resource_record_name
#   type    = aws_acm_certificate.example.domain_validation_options[0].resource_record_type
#   value   = aws_acm_certificate.example.domain_validation_options[0].resource_record_value
#   ttl     = 300
# }