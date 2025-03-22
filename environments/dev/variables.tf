variable "region" {
  description = "AWS Region"
  type        = string
  default     = "ap-northeast-2"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}
   
variable "vpc_id" {
  description = "VPC ID for security group"
  type        = string
  default     = "vpc-0f9a483ff58d2a6ba" # 실제 VPC ID로 변경
}

variable "allowed_ssh_cidrs" {
  description = "List of CIDR blocks allowed to SSH"
  type        = list(string)
  default     = ["10.0.0.0/8"] # 실제 허용된 IP 범위로 변경
}