locals {
  s3_origin_id = "myS3Origin"
  account_id = data.aws_caller_identity.current.account_id
  lambda_name = "crc-lambda"
  table_name  = "Visits"
  methods = toset(["GET", "POST"])
}