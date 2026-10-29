module "modules" {
  source = "./modules"
  servers = 2
  
}

output "ips_publicos" {
  description = "Lista dos IPs das instâncias criadas"
  value = module.modules.ips_publicos
}

output "alb_dns_name" {
  description = "Acesse sua aplicação por este endereço DNS"
  value       = module.modules.alb_dns_name
}