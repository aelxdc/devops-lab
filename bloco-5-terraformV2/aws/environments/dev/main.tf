

# 1. Módulo oficial consumido do Registry (atende requisito)
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "vpc-dev"
  cidr = "10.0.0.0/16"

  azs            = ["us-east-1a", "us-east-1b"]
  public_subnets = ["10.0.1.0/24", "10.0.2.0/24"]

  tags = {
    Environment = "dev"
    Project     = "DevOps-Lab"
  }
}

#Módulo consumido localmente
module "app_cluster" {
  source = "../../modules/app_cluster"

  vpc_id        = module.vpc.vpc_id
  subnets       = module.vpc.public_subnets
  instance      = "t3.micro"
  servers       = 2
  name_instance = "api-dev"
}

output "dns_alb_dev" {
  value = module.app_cluster.alb_dns_name
}