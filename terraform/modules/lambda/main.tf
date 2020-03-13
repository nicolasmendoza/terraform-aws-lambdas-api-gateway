
# IAM role which dictates what other AWS services the Lambda function
# https://awspolicygen.s3.amazonaws.com/policygen.html
resource "aws_iam_role" "terraform_identity_lambda_role" {
  name = "LambdaIdentityAdapterRole"
  assume_role_policy = file("${path.module}/terraform-lambda-assume-policy.json")
  #assume_role_policy = "${file("${path.module}/terraform-lambda-assume-policy.json")}"
}

# https://www.terraform.io/docs/providers/archive/d/archive_file.html
# TODO implement webpack and/or delegate build CI to pipeline.
variable "build_version" {
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.root}/../service/src/"
  output_path =  "${path.root}/../build/deploy-${ var.build_version }.zip"
}

resource "aws_lambda_function" "lambda_verify_token" {
  function_name = "IdentityVerifyToken"
  description = "Verify token..."

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  role = aws_iam_role.terraform_identity_lambda_role.arn

  handler = "handlers/verifyToken/index.handler"

  runtime = "nodejs10.x"
}
# https://www.terraform.io/docs/configuration/outputs.html
output "path_zip_file" {
  value = aws_lambda_function.lambda_verify_token.invoke_arn
  description = "Lambda verifyToken ARN"
}

# https://www.terraform.io/docs/configuration/outputs.html
output "lambda_verify_token" {
  value = aws_lambda_function.lambda_verify_token.invoke_arn
  description = "Lambda verifyToken ARN"
}

output "lambda_verify_token_function_name" {
  value = aws_lambda_function.lambda_verify_token.function_name
  description = "Lambda verifyToken function name"
}
