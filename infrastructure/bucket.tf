# S3 bucket for static website
resource "aws_s3_bucket" "crc-bucket" {
  provider = aws.kduncan
  bucket   = "crc-bucket-pp"

  tags = {
    Name = "crc"
  }
}

# Cross-Origin Resource Sharing (CORS) config for bucket
resource "aws_s3_bucket_cors_configuration" "example" {
  provider = aws.kduncan
  bucket   = aws_s3_bucket.crc-bucket.id
  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD"]
    allowed_origins = ["*"]
    max_age_seconds = 3000
  }
}

# Static website files
resource "aws_s3_object" "javascript" {
  provider = aws.kduncan
  bucket   = aws_s3_bucket.crc-bucket.id
  key      = "javascript/app.js"
  source   = "../javascript/app.js"
}

resource "aws_s3_object" "index" {
  provider     = aws.kduncan
  bucket       = aws_s3_bucket.crc-bucket.id
  key          = "index.html"
  source       = "../index.html"
  content_type = "text/html"
}

resource "aws_s3_object" "style" {
  provider     = aws.kduncan
  bucket       = aws_s3_bucket.crc-bucket.id
  key          = "style.css"
  source       = "../style.css"
  content_type = "text/css"
}

# Static website files - assets folder
resource "aws_s3_object" "asset" {
  provider = aws.kduncan
  for_each = toset([
    "briefcase-solid.svg",
    "cloudydaiyz-logo.png",
    "images/headshot.png",
    "images/linkedin-1.jpeg",
    "images/linkedin-2.jpeg",
    "images/linkedin-3.jpeg",
    "images/linkedin-4.jpeg",
    "images/take-action-award.jpg",
    "projects/deep-interest-validator.png",
    "projects/interactive-comments.png",
    "projects/membership-logger.png",
    "projects/youtube-to-spotify.png",
    "skills/amazonwebservices.svg",
    "skills/css3.svg",
    "skills/docker.svg",
    "skills/html5.svg",
    "skills/java.svg",
    "skills/javascript.svg",
    "skills/python.svg",
    "skills/terraform.svg",
    "skills/typescript.svg",
  ])

  bucket = aws_s3_bucket.crc-bucket.id
  key    = "assets/${each.key}"
  source = "../assets/${each.key}"
}

# Static website config, disabling because can't use OAC with static website hosting
# functionality.
# https://www.stormit.cloud/blog/cloudfront-origin-access-identity/
# resource "aws_s3_bucket_website_configuration" "crc-web-config" {
#   provider = aws.default
#   bucket = aws_s3_bucket.crc-bucket.id

#   index_document {
#     suffix = "index.html"
#   }
# }

# Disable all block public access
resource "aws_s3_bucket_public_access_block" "example" {
  provider = aws.kduncan
  bucket   = aws_s3_bucket.crc-bucket.id
}

# Object ownership controls
resource "aws_s3_bucket_ownership_controls" "example" {
  provider = aws.kduncan
  bucket   = aws_s3_bucket.crc-bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# ACL for the entire bucket (instead of having to do acl = "public-read" for each
# S3 object defined earlier in the file)
resource "aws_s3_bucket_acl" "example" {
  provider   = aws.kduncan
  depends_on = [aws_s3_bucket_ownership_controls.example]

  bucket = aws_s3_bucket.crc-bucket.id
  acl    = "public-read"
}