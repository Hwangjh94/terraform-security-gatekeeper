provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    bucket         = "mybuckettest94"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-locks"
    encrypt        = true
  }
}

module "aws_config" {
  source = "../../modules/security-checks"
  
  environment = "dev"
}

# 여기에 실제 인프라 리소스 추가         