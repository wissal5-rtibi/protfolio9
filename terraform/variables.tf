variable "region" {
  description = "Région AWS"
  default     = "us-east-1"
}

variable "ami_id" {
  description = "AMI Ubuntu 22.04 LTS"
  default     = "ami-0c7217cdde317cfec"
}

variable "instance_type" {
  description = "Type d'instance EC2"
  default     = "t2.micro"
}

variable "key_name" {
  description = "Nom de la paire de clés SSH"
  default     = "ma-cle-aws"
}

variable "vpc_cidr" {
  description = "CIDR block du VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDRs des subnets publics"
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDRs des subnets privés"
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "availability_zones" {
  description = "Zones de disponibilité"
  default     = ["us-east-1a", "us-east-1b"]
}
