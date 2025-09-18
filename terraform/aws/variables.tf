variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-2" # Sydney
}

variable "key_name" {
  description = "Name to assign to the AWS key pair"
  type        = string
  default     = "finaltask"
}

variable "public_key_path" {
  description = "Path to the public key file"
  type        = string
  default     = "~/.ssh/finaltask.pub"
}

variable "app_instance_type" {
  description = "Instance type for the application server"
  type        = string
  default     = "t3.small"
}

variable "gateway_instance_type" {
  description = "Instance type for the gateway server"
  type        = string
  default     = "t3.micro"
}
