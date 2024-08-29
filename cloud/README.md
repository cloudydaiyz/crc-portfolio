# infrastructure

To plan:
`terraform plan`

To deploy:
`terraform apply --auto-approve`

To redeploy the API gateway (after making changes to the gateway):
`terraform apply -replace aws_api_gateway_deployment.example --auto-approve`

To redeploy the DynamoDB table (resetting the counters):
`terraform apply -replace="aws_dynamodb_table.crc-table" --auto-approve`
