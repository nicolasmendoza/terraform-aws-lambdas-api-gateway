variable "build_version" {
}

module "lambda"{
  source = "./../lambda"
  build_version = var.build_version
}

# https://www.terraform.io/docs/providers/aws/r/api_gateway_rest_api.html
resource "aws_api_gateway_rest_api" "identity_gateway_api" {
  name        = "ServerlessIdentityAPI"
  description = "API for Identity Adapter"
}

# https://www.terraform.io/docs/providers/aws/d/api_gateway_resource.html
resource "aws_api_gateway_resource" "resource_verify_token" {
  rest_api_id = aws_api_gateway_rest_api.identity_gateway_api.id
  parent_id = aws_api_gateway_rest_api.identity_gateway_api.root_resource_id
  path_part = "authorize"
}


# https://www.terraform.io/docs/providers/aws/r/api_gateway_method.html
resource "aws_api_gateway_method" "method_verify_token" {
  rest_api_id   = aws_api_gateway_rest_api.identity_gateway_api.id
  resource_id   = aws_api_gateway_resource.resource_verify_token.id
  http_method   = "POST"
  authorization = "NONE"
}

# https://www.terraform.io/docs/providers/aws/r/api_gateway_integration.html
resource "aws_api_gateway_integration" "verify_token_integration" {
  rest_api_id = aws_api_gateway_rest_api.identity_gateway_api.id
  resource_id = aws_api_gateway_resource.resource_verify_token.id
  http_method = aws_api_gateway_method.method_verify_token.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.lambda.verify_token_invoke_arn
}

# :::::::::::::::::::::::: getby Email :::::::::::::::::::::::::::::::

# https://www.terraform.io/docs/providers/aws/d/api_gateway_resource.html

# https://www.terraform.io/docs/providers/aws/d/api_gateway_resource.html
resource "aws_api_gateway_resource" "resource_get_identity_by_email" {
  rest_api_id = aws_api_gateway_rest_api.identity_gateway_api.id
  parent_id = aws_api_gateway_rest_api.identity_gateway_api.root_resource_id
  path_part = "identity-by-email"
}


# https://www.terraform.io/docs/providers/aws/r/api_gateway_method.html
resource "aws_api_gateway_method" "method_get_identity_by_email" {
  rest_api_id   = aws_api_gateway_rest_api.identity_gateway_api.id
  resource_id   = aws_api_gateway_resource.resource_get_identity_by_email.id
  http_method   = "POST"
  authorization = "NONE"
}

# https://www.terraform.io/docs/providers/aws/r/api_gateway_integration.html
resource "aws_api_gateway_integration" "get_identity_by_email_integration" {
  rest_api_id = aws_api_gateway_rest_api.identity_gateway_api.id
  resource_id = aws_api_gateway_resource.resource_get_identity_by_email.id
  http_method = aws_api_gateway_method.method_get_identity_by_email.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.lambda.lambda_get_identity_by_email_arn
}

# ::::: End get by Email:::::

#https://www.terraform.io/docs/providers/aws/r/api_gateway_deployment.html
resource "aws_api_gateway_deployment" "test_app" {
  depends_on = [
    "aws_api_gateway_resource.resource_verify_token",
    "aws_api_gateway_resource.resource_get_identity_by_email",
    "aws_api_gateway_resource.resource_get_email_by_identity",
    "aws_api_gateway_resource.resource_redirect"
  ]

  rest_api_id = aws_api_gateway_rest_api.identity_gateway_api.id
  stage_name  = "test"
}

# ::::::::::::::::::::::::  getEmailByIdentity :::::::::::::::::::::::::::::::


# https://www.terraform.io/docs/providers/aws/d/api_gateway_resource.html
resource "aws_api_gateway_resource" "resource_get_email_by_identity" {
  rest_api_id = aws_api_gateway_rest_api.identity_gateway_api.id
  parent_id = aws_api_gateway_rest_api.identity_gateway_api.root_resource_id
  path_part = "email-by-identity"
}


# https://www.terraform.io/docs/providers/aws/r/api_gateway_method.html
resource "aws_api_gateway_method" "method_get_email_by_identity" {
  rest_api_id   = aws_api_gateway_rest_api.identity_gateway_api.id
  resource_id   = aws_api_gateway_resource.resource_get_email_by_identity.id
  http_method   = "POST"
  authorization = "NONE"
}

# https://www.terraform.io/docs/providers/aws/r/api_gateway_integration.html
resource "aws_api_gateway_integration" "get_email_by_identity_integration" {
  rest_api_id = aws_api_gateway_rest_api.identity_gateway_api.id
  resource_id = aws_api_gateway_resource.resource_get_email_by_identity.id
  http_method = aws_api_gateway_method.method_get_email_by_identity.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.lambda.lambda_get_email_by_identity_arn
}


# ::::::::::::: Redirect ::::::::::::::::::::

# https://www.terraform.io/docs/providers/aws/d/api_gateway_resource.html
resource "aws_api_gateway_resource" "resource_redirect" {
  rest_api_id = aws_api_gateway_rest_api.identity_gateway_api.id
  parent_id = aws_api_gateway_rest_api.identity_gateway_api.root_resource_id
  path_part = "redirect"
}


# https://www.terraform.io/docs/providers/aws/r/api_gateway_method.html
resource "aws_api_gateway_method" "method_redirect" {
  rest_api_id   = aws_api_gateway_rest_api.identity_gateway_api.id
  resource_id   = aws_api_gateway_resource.resource_redirect.id
  http_method   = "POST"
  authorization = "NONE"
}

# https://www.terraform.io/docs/providers/aws/r/api_gateway_integration.html
resource "aws_api_gateway_integration" "redirect_integration" {
  rest_api_id = aws_api_gateway_rest_api.identity_gateway_api.id
  resource_id = aws_api_gateway_resource.resource_redirect.id
  http_method = aws_api_gateway_method.method_redirect.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.lambda.lambda_redirect_arn
}

# :::::::::::::::::: Permissions ::::::::::::::::::::

resource "aws_lambda_permission" "lambda_verify_token_permission" {
  statement_id  = "AllowVerifyTokenAPIInvoke"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda.lambda_verify_token_function_name
  principal     = "apigateway.amazonaws.com"

  # The /*/*/* part allows invocation from any stage, method and resource path
  # within API Gateway REST API.
  source_arn = "${aws_api_gateway_rest_api.identity_gateway_api.execution_arn}/*/*/*"
}

resource "aws_lambda_permission" "lambda_get_identity_by_email_permission" {
  statement_id  = "AllowGetIdentityByEmailAPIInvoke"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda.lambda_get_identity_by_email_name
  principal     = "apigateway.amazonaws.com"

  # The /*/*/* part allows invocation from any stage, method and resource path
  # within API Gateway REST API.
  source_arn = "${aws_api_gateway_rest_api.identity_gateway_api.execution_arn}/*/*/*"
}

resource "aws_lambda_permission" "lambda_get_email_by_identity_permission" {
  statement_id  = "AllowGetEmailByIdentityAPIInvoke"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda.lambda_get_email_by_identity_name
  principal     = "apigateway.amazonaws.com"

  # The /*/*/* part allows invocation from any stage, method and resource path
  # within API Gateway REST API.
  source_arn = "${aws_api_gateway_rest_api.identity_gateway_api.execution_arn}/*/*/*"
}

resource "aws_lambda_permission" "lambda_redirect_permission" {
  statement_id  = "AllowGetIdentityByEmailAPIInvoke"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda.lambda_redirect_name
  principal     = "apigateway.amazonaws.com"

  # The /*/*/* part allows invocation from any stage, method and resource path
  # within API Gateway REST API.
  source_arn = "${aws_api_gateway_rest_api.identity_gateway_api.execution_arn}/*/*/*"
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
  value = aws_api_gateway_deployment.test_app.invoke_url
}