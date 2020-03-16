# https://www.terraform.io/docs/providers/archive/d/archive_file.html
data "archive_file" "jsonwebtoken_layer_zip" {
  type        = "zip"
  source_dir  = "${path.root}/../service/node_modules/jsonwebtoken"
  output_path =  "${path.root}/../build/jsonwebtoken.zip"
}

resource "aws_lambda_layer_version" "json_webtoken_layer" {
  description = "AWS lambda layer node modules"
  layer_name = "node_modules"
  filename = data.archive_file.jsonwebtoken_layer_zip.output_path
  compatible_runtimes = [
    "nodejs10.x"
  ]
}

