terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.5.0"
}

provider "aws" {
  region  = var.aws_region
  profile = "finaltask"
}

###############################
# Key Pair (uses your local ~/.ssh/finaltask.pub)
###############################
resource "aws_key_pair" "finaltask" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}

###############################
# Security Group (HTTP/HTTPS/SSH:6969)
###############################
data "aws_vpc" "default" {
  default = true
}

resource "aws_security_group" "finaltask" {
  name        = "finaltask-sydney"
  description = "Security group for final task EC2 instances (Sydney)"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow SSH on custom port"
    from_port   = 6969
    to_port     = 6969
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

###############################
# Ubuntu 22.04 LTS AMI (Jammy)
###############################
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

###############################
# EC2 Instances
###############################
resource "aws_instance" "appserver" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.app_instance_type
  key_name               = aws_key_pair.finaltask.key_name
  vpc_security_group_ids = [aws_security_group.finaltask.id]

  tags = {
    Name = "finaltask-appserver"
    Role = "appserver"
  }

  # Root disk (gp3, 50GB)
  root_block_device {
    volume_type           = "gp3"
    volume_size           = 50
    delete_on_termination = true
  }

  user_data = <<-EOF
              #!/bin/bash
              sed -i 's/^#\?Port\s\+22/Port 6969/' /etc/ssh/sshd_config
              systemctl restart ssh
              EOF
}

resource "aws_instance" "gateway" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.gateway_instance_type
  key_name               = aws_key_pair.finaltask.key_name
  vpc_security_group_ids = [aws_security_group.finaltask.id]

  tags = {
    Name = "finaltask-gateway"
    Role = "gateway"
  }

  # Root disk (gp3, 50GB)
  root_block_device {
    volume_type           = "gp3"
    volume_size           = 50
    delete_on_termination = true
  }

  user_data = <<-EOF
              #!/bin/bash
              sed -i 's/^#\?Port\s\+22/Port 6969/' /etc/ssh/sshd_config
              systemctl restart ssh
              EOF
}

###############################
# Outputs
###############################
output "appserver_public_ip" {
  value       = aws_instance.appserver.public_ip
  description = "Public IP of the application server"
}

output "gateway_public_ip" {
  value       = aws_instance.gateway.public_ip
  description = "Public IP of the gateway server"
}
