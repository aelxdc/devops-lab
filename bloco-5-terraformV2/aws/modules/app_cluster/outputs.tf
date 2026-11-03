output "alb_dns_name" {
  description = "DNS público gerado para o Application Load Balancer"
  value       = aws_lb.app_lb.dns_name
}

output "ips_publicos" {
  description = "Lista dos IPs públicos associados às instâncias EC2"
  value       = aws_instance.ec2create[*].public_ip
}

output "alb_arn" {
  description = "ARN do Application Load Balancer"
  value       = aws_lb.app_lb.arn
}

output "security_group_id" {
  description = "ID do Security Group criado para o cluster"
  value       = aws_security_group.security_group_web_ssh.id
}