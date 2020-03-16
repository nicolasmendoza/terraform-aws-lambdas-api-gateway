output "jsonwebtoken_layer_arn" {
  value = aws_lambda_layer_version.json_webtoken_layer.arn
  description = "AWS layer for jsonwebtoken dependency"
}


