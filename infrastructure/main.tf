# Provider blocks
# This one for certificate management
provider "aws" {
  alias = "us_east_1"
  region  = "us-east-1"
  profile = "kduncan"
}

# This one for resources
provider "aws" {
  alias = "default"
  region  = "us-east-2"
  profile = "kduncan"
}