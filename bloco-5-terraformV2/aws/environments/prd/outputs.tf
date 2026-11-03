output "app_url" {
  description = "URL de acesso à aplicação em Produção via ALB"
  value       = "http://${module.app_cluster.alb_dns_name}"
}

output "ec2_public_ips" {
  description = "IPs públicos das instâncias de Produção"
  value       = module.app_cluster.ips_publicos
}

output "vpc_id" {
  description = "ID da VPC de Produção"
  value       = module.vpc.vpc_id
}