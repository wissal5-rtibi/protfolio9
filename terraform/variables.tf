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
