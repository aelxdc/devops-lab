module "modules" {
  source = "./modules"
  servers = 2
  providers = {
    aws = aws.use1
  }
}

module "modules2" {
  source = "./modules"
  servers = 2
  providers = {
    aws = aws.use2
  }
}

output "ips_publicos" {
  description = "Lista dos IPs das instâncias criadas"
  value = module.modules.ips_publicos
}
output "ips_publicos2" {
  value = module.modules2.ips_publicos
}

output "alb_dns_name" {
  description = "Acesse sua aplicação por este endereço DNS"
  value       = module.modules.alb_dns_name
}
output "alb_dns_name2" {
  value       = module.modules2.alb_dns_name
}