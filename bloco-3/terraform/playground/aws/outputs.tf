output "ips_publicos" {
  description = "Lista dos IPs das instâncias criadas"
  value = aws_instance.example[*].public_ip  
}

output "alb_dns_name" {
  description = "Acesse sua aplicação por este endereço DNS"
  value       = aws_lb.app_lb.dns_name
}