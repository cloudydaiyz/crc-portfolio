# REST API API Gateway
resource "aws_api_gateway_rest_api" "example" {
  provider = aws.kduncan
  name = "terrapi"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# Resource for API Gateway (the path, this one is /{example} where {example} is
# a path parameter)
resource "aws_api_gateway_resource" "example" {
  provider = aws.kduncan
  rest_api_id = aws_api_gateway_rest_api.example.id
  parent_id   = aws_api_gateway_rest_api.example.root_resource_id
  path_part   = "{counter-type}"
}

# locals {
# 	methods = toset(["GET", "POST"])
# }

# HTTP Methods for API Gateway
resource "aws_api_gateway_method" "example" { # GET and POST methods
  provider = aws.kduncan
	for_each = local.methods

  authorization = "NONE"
  # http_method   = "GET"
  http_method   = each.key
  resource_id   = aws_api_gateway_resource.example.id
  rest_api_id   = aws_api_gateway_rest_api.example.id
}

# AWS backend integration (and integration request) for API Gateway (lambda for this gateway)
resource "aws_api_gateway_integration" "example" {
  provider = aws.kduncan
	for_each = local.methods

  # http_method = aws_api_gateway_method.example.http_method
  http_method = each.key
  resource_id = aws_api_gateway_resource.example.id
  rest_api_id = aws_api_gateway_rest_api.example.id

  # Lambda function can only be invoked via POST.
  # https://github.com/awslabs/aws-apigateway-importer/issues/9#issuecomment-129651005
  integration_http_method = "POST"
  type                    = "AWS"

  # Invoke URI of the lambda function
  # uri = "arn:aws:apigateway:${local.region}:lambda:path/2015-03-31/functions/${aws_lambda_function.test_lambda.arn}/invocations"
  uri = aws_lambda_function.test_lambda.invoke_arn

  # Integration request - mapping template
  request_templates = {
    # Transforms incoming JSON request to detailed JSON request
    "application/json" = <<EOF
##  See https://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-mapping-template-reference.html
##  This template will pass through all parameters including path, querystring, header, stage variables, and context through to the integration endpoint via the body/payload
#set($allParams = $input.params())
{
"body-json" : $input.json('$'),
"params" : {
#foreach($type in $allParams.keySet())
    #set($params = $allParams.get($type))
"$type" : {
    #foreach($paramName in $params.keySet())
    "$paramName" : "$util.escapeJavaScript($params.get($paramName))"
        #if($foreach.hasNext),#end
    #end
}
    #if($foreach.hasNext),#end
#end
},
"stage-variables" : {
#foreach($key in $stageVariables.keySet())
"$key" : "$util.escapeJavaScript($stageVariables.get($key))"
    #if($foreach.hasNext),#end
#end
},
"context" : {
    "account-id" : "$context.identity.accountId",
    "api-id" : "$context.apiId",
    "api-key" : "$context.identity.apiKey",
    "authorizer-principal-id" : "$context.authorizer.principalId",
    "caller" : "$context.identity.caller",
    "cognito-authentication-provider" : "$context.identity.cognitoAuthenticationProvider",
    "cognito-authentication-type" : "$context.identity.cognitoAuthenticationType",
    "cognito-identity-id" : "$context.identity.cognitoIdentityId",
    "cognito-identity-pool-id" : "$context.identity.cognitoIdentityPoolId",
    "http-method" : "$context.httpMethod",
    "stage" : "$context.stage",
    "source-ip" : "$context.identity.sourceIp",
    "user" : "$context.identity.user",
    "user-agent" : "$context.identity.userAgent",
    "user-arn" : "$context.identity.userArn",
    "request-id" : "$context.requestId",
    "resource-id" : "$context.resourceId",
    "resource-path" : "$context.resourcePath"
    }
}
EOF

    # Transforms incoming XML request to JSON
    # 	"application/xml" = <<EOF
    # {
    #    "body" : $input.json('$')
    # }
    # EOF
  }
}

# Method response for the gateway (view console under Resource tab for example)
resource "aws_api_gateway_method_response" "response_200" {
  provider = aws.kduncan
	for_each = local.methods
	
  rest_api_id = aws_api_gateway_rest_api.example.id
  resource_id = aws_api_gateway_resource.example.id
  # http_method = aws_api_gateway_method.example.http_method
  http_method = each.key
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin" = true
  }

	depends_on = [
		aws_api_gateway_integration.example
	]
}

# Integraiton response for the gateway (view console under Resource tab for example)
resource "aws_api_gateway_integration_response" "example" {
  provider = aws.kduncan
	for_each = local.methods

  rest_api_id = aws_api_gateway_rest_api.example.id
  resource_id = aws_api_gateway_resource.example.id
  # http_method = aws_api_gateway_method.example.http_method
  http_method = each.key

	# https://developer.hashicorp.com/terraform/language/meta-arguments/for_each#referring-to-instances
  status_code = aws_api_gateway_method_response.response_200[each.key].status_code

  # Transforms the incoming backend JSON response to XML
	# 	response_templates = {
	# 		"application/xml" = <<EOF
	# #set($inputRoot = $input.path('$'))
	# <?xml version="1.0" encoding="UTF-8"?>
	# <message>
	# 		$inputRoot.body
	# </message>
	# EOF
	# 	}

  # Headers to prevent conflict with CORS
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,X-Amz-User-Agent'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

	depends_on = [
		aws_api_gateway_integration.example
	]
}

# Configures how the API Gateway is deployed
# To redeploy API Gateway to reflect changes, replace this
resource "aws_api_gateway_deployment" "example" {
  provider = aws.kduncan
  rest_api_id = aws_api_gateway_rest_api.example.id

  # triggers = {
  #   # NOTE: The configuration below will satisfy ordering considerations,
  #   #       but not pick up all future REST API changes. More advanced patterns
  #   #       are possible, such as using the filesha1() function against the
  #   #       Terraform configuration file(s) or removing the .id references to
  #   #       calculate a hash against whole resources. Be aware that using whole
  #   #       resources will show a difference after the initial implementation.
  #   #       It will stabilize to only change when resources change afterwards.
  #   redeployment = sha1(jsonencode([
  #     aws_api_gateway_resource.example.id,
  #     aws_api_gateway_method.example.id,
  #     aws_api_gateway_integration.example.id,
  #   ]))
  # }

  # https://developer.hashicorp.com/terraform/language/meta-arguments/lifecycle#create_before_destroy
  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_method.example
    
  ]
}

# Stage for API Gateway (dev/prod)
# Could use stage_name with the api_gateway_deployment resource instead, but using
# this resource is recommended
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_deployment#stage_name
resource "aws_api_gateway_stage" "example" {
  provider = aws.kduncan
  deployment_id = aws_api_gateway_deployment.example.id
  rest_api_id   = aws_api_gateway_rest_api.example.id
  stage_name    = "prod"
}

# Gives the API Gateway permission to trigger the lambda function
# By default any two AWS services have no access to one another, until access is explicitly granted
# From Lambda console - Resource-based policy statements: A resource-based policy 
# lets you grant permissions to other AWS accounts or services on a per-resource basis.
resource "aws_lambda_permission" "apigw_permission" {
  provider = aws.kduncan
  statement_id  = "AllowGetExecutionFromApiGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.test_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  # If you specify a wildcard (*), the Resource expression applies the wildcard to the rest of the expression
  # http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  # https://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html#api-gateway-calling-api-permissions

  # source_arn    = "arn:aws:execute-api:${local.region}:${local.account_id}:${aws_api_gateway_rest_api.example.id}/*/${aws_api_gateway_method.example.http_method}/${aws_api_gateway_resource.example.path}"
  # source_arn    = "arn:aws:execute-api:${local.region}:${local.account_id}:${aws_api_gateway_rest_api.example.id}/*"
  source_arn = "${aws_api_gateway_rest_api.example.execution_arn}/*"

  lifecycle {
    replace_triggered_by = [
      aws_lambda_function.test_lambda
    ]
  }
}

output "base_url" {
  value = aws_api_gateway_deployment.example.invoke_url
}