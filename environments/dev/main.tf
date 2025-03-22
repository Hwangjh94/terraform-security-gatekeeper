provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    bucket         = "YOUR_STATE_BUCKET_NAME"  # 실제 생성한 버킷 이름으로 변경
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-locks"
    encrypt        = true
  }
}

module "security_checks" {
  source = "../../modules/security-checks"
  
  environment = var.environment
}

# Drift 감지를 위한 예제 리소스
resource "aws_s3_bucket" "example_bucket" {
  bucket = "example-bucket-${var.environment}-${random_string.suffix.result}"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

# 네트워크 보안 그룹 설정 (예시)
resource "aws_security_group" "example" {
  name        = "example-security-group"
  description = "Example security group with strict rules"
  vpc_id      = var.vpc_id

  # 인바운드 규칙 - 특정 IP만 SSH 접근 허용
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_cidrs
    description = "SSH access from specific IPs only"
  }

  # 아웃바운드 규칙 - 모든 트래픽 허용
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name        = "example-sg"
    Environment = var.environment
    ManagedBy   = "terraform"   
  }
}