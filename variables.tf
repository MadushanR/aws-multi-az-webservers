variable "aws_region" {
  description = "AWS region to deploy resources in"
  default     = "us-east-1"
}

variable "key_name" {
  description = "AWS EC2 Key Pair name for SSH access"
  type        = string
}
