output "instance_public_ips" {
  description = "IPs publiques des instances EC2"
  value       = aws_instance.web[*].public_ip
}

output "alb_dns_name" {
  description = "DNS de l'ALB pour accéder à l'application"
  value       = aws_lb.main.dns_name
}

output "vpc_id" {
  description = "ID du VPC créé"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "IDs des subnets publics"
  value       = aws_subnet.public[*].id
}

output "frontend_url" {
  description = "URL de l'application via ALB"
  value       = "http://${aws_lb.main.dns_name}"
}
