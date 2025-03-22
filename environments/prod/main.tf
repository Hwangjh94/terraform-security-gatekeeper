provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    bucket         = "mybuckettest94"
    key            = "prod/terraform.tfstate"
    region         = "ap-northeast-2"
    dynamodb_table = "terraform-state-locks"
    encrypt        = true
  }
}

module "security_checks" {
  source = "../../modules/security-checks"

  environment = var.environment
}

# 프로덕션 환경 리소스 설정
# 개발 환경과 비슷하지만 더 엄격한 보안 설정 적용