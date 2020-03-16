Dummy Build:

###

"/users/email/{email}
4:21
"/users/{swid}
4:22
"/redirect?clientID={clientID}&callbackURL={callbackURL}




aws s3api create-bucket --bucket=build-artifacts-identity-service --region=us-east-1


Terraform will perform the following actions:

  # aws_iam_role.lambda_exec will be created
  + resource "aws_iam_role" "lambda_exec" {
      + arn                   = (known after apply)
      + assume_role_policy    = jsonencode(
            {
              + Statement = [
                  + {
                      + Action    = "sts:AssumeRole"
                      + Effect    = "Allow"
                      + Principal = {
                          + Service = "lambda.amazonaws.com"
                        }
                      + Sid       = ""
                    },
                ]
              + Version   = "2012-10-17"
            }
        )
      + create_date           = (known after apply)
      + force_detach_policies = false
      + id                    = (known after apply)
      + max_session_duration  = 3600
      + name                  = "serverless_identity_service_lambda"
      + path                  = "/"
      + unique_id             = (known after apply)
    }

  # aws_lambda_function.example will be created
  + resource "aws_lambda_function" "example" {
      + arn                            = (known after apply)
      + function_name                  = "ServerlessIdentityService"
      + handler                        = "main.handler"
      + id                             = (known after apply)
      + invoke_arn                     = (known after apply)
      + last_modified                  = (known after apply)
      + memory_size                    = 128
      + publish                        = false
      + qualified_arn                  = (known after apply)
      + reserved_concurrent_executions = -1
      + role                           = (known after apply)
      + runtime                        = "nodejs10.x"
      + s3_bucket                      = "test-build-artifacts-identity-service"
      + s3_key                         = "v0.1/app.zip"
      + source_code_hash               = (known after apply)
      + source_code_size               = (known after apply)
      + timeout                        = 3
      + version                        = (known after apply)

      + tracing_config {
          + mode = (known after apply)
        }
    }




aws s3 cp build/v0.1/app.zip s3://test-build-artifacts-identity-service

# Deployment
terraform init
terraform plan




# terraform-aws-lambdas-api-gateway
