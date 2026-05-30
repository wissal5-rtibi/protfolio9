output "instance_ip" {
  description = "IP publique du serveur EC2"
  value       = aws_eip.portfolio_eip.public_ip
}

output "frontend_url" {
  description = "URL du Frontend"
  value       = "http://${aws_eip.portfolio_eip.public_ip}:8080"
}

output "backend_url" {
  description = "URL du Backend"
  value       = "http://${aws_eip.portfolio_eip.public_ip}:5002"
}
