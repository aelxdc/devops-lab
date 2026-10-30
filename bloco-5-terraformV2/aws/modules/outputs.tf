output "ips_publicos" {
  description = "Lista dos IPs das instâncias criadas"
  value = aws_instance.ec2create[*].public_ip  
}

output "alb_dns_name" {
  description = "Acesse sua aplicação por este endereço DNS"
  value       = aws_lb.app_lb.dns_name
}