# Unneeded since the aws_iam_policy_document datasource is being used
# resource "aws_iam_policy" "lambda_policy" {
# name = "crc-lambda-policy"
# policy = <<EOF
# {
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Effect": "Allow",
#             "Action": "logs:CreateLogGroup",
#             "Resource": "arn:aws:logs:us-east-2:${local.account_id}:*"
#         },
#         {
#             "Effect": "Allow",
#             "Action": [
#                 "logs:CreateLogStream",
#                 "logs:PutLogEvents"
#             ],
#             "Resource": [
#                 "arn:aws:logs:us-east-2:${local.account_id}:log-group:/aws/lambda/example:*"
#             ]
#         },
#         {
#             "Effect": "Allow",
#             "Action": [
#                 "dynamodb:GetItem",
#                 "dynamodb:UpdateItem"
#             ],
#             "Resource": "arn:aws:dynamodb:us-east-2:${local.account_id}:table/Visits"
#         }
#     ]
# }
# EOF
# }

resource "aws_iam_role" "iam_for_lambda" {
  provider = aws.kduncan
  name = "iam_for_lambda"

  # Assume role policies are different from regular IAM policies in that they 
  # define which entities (principals) are allowed to assume the role and under 
  # what conditions, but they do not specify resource ARNs.
  # NOTE: could've also used jsonencode(json version of policy)
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  # If we were using the aws_iam_policy resource (or use aws_iam_policy_attachment)
  # managed_policy_arns = [
  #   aws_iam_policy.lambda_policy.arn
  # ]

  inline_policy {
    name   = "lambda_policy"
    policy = data.aws_iam_policy_document.lambda_policy.json
  }
}

resource "aws_lambda_function" "test_lambda" {
  provider = aws.kduncan
  
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = data.archive_file.lambda.output_path
  function_name = local.lambda_name
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "handler.lambda_handler"

  # Virtual attribute used to trigger replacement when source code changes
  # The usual way to set this is filebase64sha256("file.zip") (Terraform 0.11.12 
  # and later) where "file.zip" is the local filename of the lambda function 
  # source archive. 
  source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime = "python3.12"
}