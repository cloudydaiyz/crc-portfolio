variable "aws_access_key" {
  type        = string
  description = "AWS access key"
  sensitive   = true
  nullable    = false
}

variable "aws_secret_access_key" {
  type        = string
  description = "AWS secret access key"
  sensitive   = true
  nullable    = false
}

variable "aws_region" {
  type        = string
  description = "AWS region to deploy resources in."
  nullable    = false
}

variable "cloudflare_api_token" {
    type = string
    description = "API token for Cloudflare"
    nullable    = false
}