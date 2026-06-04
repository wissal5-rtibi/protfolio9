output "instance_public_ip" {
  value = aws_eip.web.public_ip
}

output "alb_dns_name" {
  value = "http://${aws_lb.main.dns_name}"
}
