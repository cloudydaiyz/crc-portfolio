terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
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

# Generates an archive from content, a file, or directory of files
data "archive_file" "lambda" {
  type = "zip"

  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  source_file = "${path.module}/lambda/handler.py"
  output_path = "${path.module}/lambda/handler.zip"
}

# Assume role policy for the IAM role
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    # sts:AssumeRole
    # Action that allows the principals to assume an IAM role and call AWS services
    # on your behalf
    # https://stackoverflow.com/a/44658378 
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "lambda_policy" {
  # Lambda automatically creates a log group and logs via CloudWatch Logs, so you
  # must give it permission to create CW logs
  statement {
    actions = [
      "logs:CreateLogGroup"
    ]
    resources = [
      "arn:aws:logs:${local.region}:${local.account_id}:*"
    ]
  }
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:${local.region}:${local.account_id}:log-group:/aws/lambda/${local.lambda_name}:*"
    ]
  }

  # This Lambda function will be updating the DynamoDB table, so it needs access to
  # get and update items from DynamoDB
  statement {
    actions = [
      "dynamodb:GetItem",
      "dynamodb:UpdateItem"
    ]
    resources = [
      "arn:aws:dynamodb:${local.region}:${local.account_id}:table/${local.table_name}"
    ]
  }
}