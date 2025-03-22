resource "aws_security_group" "test_sg" {
  name        = "test-sg"
  description = "Security group with open SSH"
  vpc_id      = "vpc-xxxxxxxx" # 실제 VPC ID로 바꿔도 되고 임시 값 유지해도 돼

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # 보안 이슈 (tfsec/Checkov가 잡을 예정)
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
