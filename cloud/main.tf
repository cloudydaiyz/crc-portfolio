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
  profile = "kduncan"
}

# For resources
provider "aws" {
  alias   = "kduncan"
  region  = "us-east-2"
  profile = "kduncan"
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}