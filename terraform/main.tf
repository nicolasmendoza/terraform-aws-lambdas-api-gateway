provider "aws" {
  region = "us-east-1"
}

module "api_gateway" {
  source = "./modules/api_gateway"
  build_version = "${ var.app_version }"
  # security_groups = "${ var.security_groups }"
  # subnets         = "${ var.subnets }"
}