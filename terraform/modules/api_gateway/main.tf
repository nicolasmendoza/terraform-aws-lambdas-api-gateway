variable "build_version" {
}

module "lambda"{
  source = "./../lambda"
  build_version = var.build_version
}

# https://www.terraform.io/docs/providers/aws/r/api_gateway_rest_api.html
resource "aws_api_gateway_rest_api" "identity_gateway" {
  name        = "ServerlessIdentityAPI"
  description = "API for Identity Adapter"
}

# https://www.terraform.io/docs/providers/aws/d/api_gateway_resource.html
resource "aws_api_gateway_resource" "authorize" {
  rest_api_id = aws_api_gateway_rest_api.identity_gateway.id
  parent_id = aws_api_gateway_rest_api.identity_gateway.root_resource_id
  path_part = "authorize"
}

# https://www.terraform.io/docs/providers/aws/r/api_gateway_method.html
resource "aws_api_gateway_method" "method_verify_token" {
  rest_api_id   = aws_api_gateway_rest_api.identity_gateway_rest_api.id
  resource_id   = aws_api_gateway_resource.resource_verify_token.id
  http_method   = "GET"
  authorization = "NONE"
}

# https://www.terraform.io/docs/providers/aws/r/api_gateway_integration.html
resource "aws_api_gateway_integration" "lambda_verify_token" {
  rest_api_id = aws_api_gateway_rest_api.identity_gateway_rest_api.id
  resource_id = aws_api_gateway_resource.resource_verify_token.id
  http_method = aws_api_gateway_method.method_verify_token.http_method

  integration_http_method = "GET"
  type                    = "AWS_PROXY"
  uri                     = module.lambda.lambda_verify_token
}

#https://www.terraform.io/docs/providers/aws/r/api_gateway_deployment.html
resource "aws_api_gateway_deployment" "IdentityAdapter" {
  depends_on = [
    aws_api_gateway_integration.lambda_verify_token,
  ]

  rest_api_id = aws_api_gateway_rest_api.identity_gateway_rest_api.id
  stage_name  = "test"
}


resource "aws_lambda_permission" "lambda_permission" {
  statement_id  = "AllowMyDemoAPIInvoke"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda.lambda_verify_token_function_name
  principal     = "apigateway.amazonaws.com"

  # The /*/*/* part allows invocation from any stage, method and resource path
  # within API Gateway REST API.
  source_arn = "${aws_api_gateway_rest_api.identity_gateway_rest_api.execution_arn}/*/*/*"
}


# https://www.terraform.io/docs/providers/aws/r/lambda_permission.html
#resource "aws_lambda_permission" "apigw" {
#  statement_id  = "AllowAPIGatewayInvoke"
#  action        = "lambda:InvokeFunction"
#  function_name = [module.lambda.lambda_verify_token_function_name]
#  principal     = "apigateway.amazonaws.com"

  # The "/*/*" portion grants access from any method on any resource
  # within the API Gateway REST API.
 # source_arn = "${aws_api_gateway_rest_api.identity_gateway_rest_api.execution_arn}/*/*"
#}


output "base_url" {
  value = aws_api_gateway_deployment.IdentityAdapter.invoke_url
}