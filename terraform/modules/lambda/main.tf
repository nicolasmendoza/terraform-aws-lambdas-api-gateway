
# IAM role which dictates what other AWS services the Lambda function
# https://awspolicygen.s3.amazonaws.com/policygen.html
resource "aws_iam_role" "terraform_identity_lambda_role" {
  name = "LambdaIdentityAdapterRole"
  assume_role_policy = file("${path.module}/terraform-lambda-assume-policy.json")
}


# TODO implement webpack and/or delegate build CI to pipeline.
variable "build_version" {
}

# https://www.terraform.io/docs/providers/archive/d/archive_file.html
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.root}/../service/src/"
  output_path =  "${path.root}/../build/deploy-${ var.build_version }.zip"
}

#:::::::::::::::::: Lambda function : verifyToken
resource "aws_lambda_function" "lambda_verify_token" {
  function_name = "IdentityVerifyToken"
  description = "Lambda function for verifyToken"

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  role = aws_iam_role.terraform_identity_lambda_role.arn

  handler = "handlers/verifyToken/index.handler"

  runtime = "nodejs10.x"
}

#:::::::::::::::: Lambda function: getIdentityByEmail
resource "aws_lambda_function" "lambda_get_identity_by_email" {
  function_name = "GetIdentityByEmail"
  description = "Lambda function for getIdentityByEmail"

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  role = aws_iam_role.terraform_identity_lambda_role.arn

  handler = "handlers/getIdentityByEmail/index.handler"

  runtime = "nodejs10.x"
}


#:::::::::::::::: Lambda function: getEmailByIdentity
resource "aws_lambda_function" "lambda_get_email_by_identity" {
  function_name = "GetIdentityEmailByID"
  description = "Lambda function for getIdentityEmailByID"

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  role = aws_iam_role.terraform_identity_lambda_role.arn

  handler = "handlers/getEmailByIdentity/index.handler"

  runtime = "nodejs10.x"
}


#:::::::::::::::: Lambda function: Redirect
resource "aws_lambda_function" "lambda_redirect" {
  function_name = "redirect"
  description = "Lambda function for redirect"

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  role = aws_iam_role.terraform_identity_lambda_role.arn

  handler = "handlers/redirect/index.handler"

  runtime = "nodejs10.x"
}


# https://www.terraform.io/docs/configuration/outputs.html
output "path_zip_file" {
  value = aws_lambda_function.lambda_verify_token.invoke_arn
  description = "Lambda verifyToken ARN"
}

/*
Here exports lambda function._name's and lambda.invoke_arn for each Handler.
Example:
  output "lambda_name" {
    value = aws_lambda_function.lambda_name.invoke_arn
    description = "Lambda description var"
  }

  output "lambda_name_function_name" {
    value = aws_lambda_function.lambda_name.function_name
    description = "Lambda function name var"
  }

*/

# https://www.terraform.io/docs/configuration/outputs.html
output "verify_token_invoke_arn" {
  value = aws_lambda_function.lambda_verify_token.invoke_arn
  description = "Lambda verifyToken ARN"
}

output "lambda_verify_token_function_name" {
  value = aws_lambda_function.lambda_verify_token.function_name
  description = "Lambda verifyToken function name"
}

#::::::::::::::::

output "lambda_get_identity_by_email_arn" {
  value = aws_lambda_function.lambda_get_identity_by_email.invoke_arn
  description = ""
}

output "lambda_get_identity_by_email_name" {
  value = aws_lambda_function.lambda_get_identity_by_email.function_name
  description = ""
}

# ::::::::::::::::::::

output "lambda_get_email_by_identity_arn" {
  value = aws_lambda_function.lambda_get_email_by_identity.invoke_arn
  description = ""
}

output "lambda_get_email_by_identity_name" {
  value = aws_lambda_function.lambda_get_email_by_identity.function_name
  description = ""
}

# ::::::::::::::::

output "lambda_redirect_arn" {
  value = aws_lambda_function.lambda_redirect.invoke_arn
  description = ""
}

output "lambda_redirect_name" {
  value = aws_lambda_function.lambda_redirect.function_name
  description = ""
}


