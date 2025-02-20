terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

# Provider blocks
# For certificate management
provider "aws" {
  alias   = "us_east_1"
  region  = "us-east-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_access_key
}

# For resources
provider "aws" {
  alias   = "kduncan"
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_access_key
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

data "aws_caller_identity" "current" {
  provider = aws.kduncan
}