variable "region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

variable "vpc_id" {
  description = "VPC ID for security group"
  type        = string
  default     = "vpc-87654321" # 실제 VPC ID로 변경
}

variable "allowed_ssh_cidrs" {
  description = "List of CIDR blocks allowed to SSH"
  type        = list(string)
  default     = ["10.0.0.0/16"] # 실제 허용된 IP 범위로 변경
}