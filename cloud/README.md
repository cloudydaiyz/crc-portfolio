# infrastructure

Originally, this architecture included S3, CloudFront for static website hosting. To maximize cost savings, I decided to go with hosting the static website on Cloudflare Pages instead. The old S3 and Cloudfront code can be found in the `archive` directory.

## Commands

To plan:
`terraform plan`

To deploy:
`terraform apply --auto-approve`

To redeploy the API gateway (after making changes to the gateway):
`terraform apply -replace aws_api_gateway_deployment.example --auto-approve`

To redeploy the DynamoDB table (resetting the counters):
`terraform apply -replace="aws_dynamodb_table.crc-table" --auto-approve`
