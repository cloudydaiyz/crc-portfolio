# DynamoDB table to store counters
resource "aws_dynamodb_table" "crc-table" {
  provider = aws.kduncan
  name           = "Visits"
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "Type" # partition key
  range_key      = "CounterID" # sort key

  attribute {
    name = "Type"
    type = "S"
  }

  attribute {
    name = "CounterID"
    type = "N"
  }
}

# For items that will be changed in a DynamoDB table, you should declare them
# in the table instead of in Terraform -- it could reset the values on reapply.
# resource "aws_dynamodb_table_item" "portfolio-views" {
#   table_name = aws_dynamodb_table.crc-table.name
#   hash_key   = aws_dynamodb_table.crc-table.hash_key

#   item = <<ITEM
# {
#   "Type": {"S": "portfolio"},
#   "Amount": {"N": "0"},
# }
# ITEM
# }