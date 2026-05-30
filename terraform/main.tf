terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# Security Group
resource "aws_security_group" "portfolio_sg" {
  name        = "portfolio-sg"
  description = "Security Group pour Portfolio9"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Frontend"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Backend"
    from_port   = 5002
    to_port     = 5002
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "portfolio-sg"
  }
}

# Instance EC2
resource "aws_instance" "portfolio_server" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.portfolio_sg.id]

  tags = {
    Name = "Serveur_node"
  }

  user_data = <<-EOF
    #!/bin/bash
    apt update -y
    apt install -y docker.io docker-compose git
    systemctl start docker
    systemctl enable docker
    git clone https://github.com/wissal5-rtibi/protfolio9.git /app
    cd /app
    docker compose up --build -d
  EOF
}

# Elastic IP
resource "aws_eip" "portfolio_eip" {
  instance = aws_instance.portfolio_server.id
  tags = {
    Name = "portfolio-eip"
  }
}
