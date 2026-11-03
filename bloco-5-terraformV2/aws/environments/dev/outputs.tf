# Output consumido do módulo próprio
output "app_url" {
  description = "URL de acesso à aplicação via ALB"
  value       = "http://${module.app_cluster.alb_dns_name}"
}

output "ec2_public_ips" {
  description = "IPs públicos das instâncias provisionadas em DEV"
  value       = module.app_cluster.ips_publicos
}

# Output consumido do MÓDULO DO REGISTRY (VPC)
output "vpc_id" {
  description = "ID da VPC provisionada pelo módulo oficial"
  value       = module.vpc.vpc_id
}

output "vpc_public_subnets" {
  description = "Subnets públicas geradas para o ambiente"
  value       = module.vpc.public_subnets
}