# 1. VPC de Produção com CIDR isolado
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "vpc-prd"
  cidr = "10.1.0.0/16"

  azs            = ["us-east-1a", "us-east-1b", "us-east-1c"]
  public_subnets = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]

  tags = {
    Environment = "prd"
    Project     = "DevOps-Lab"
  }
}

# 2. Módulo de Aplicação dimensionado para Produção
module "app_cluster" {
  source = "../../modules/app_cluster"

  vpc_id        = module.vpc.vpc_id
  subnets       = module.vpc.public_subnets
  servers       = 3 # Maior disponibilidade em prd
  name_instance = "api-prd"

  tags = {
    Environment = "prd"
    Project     = "DevOps-Lab"
  }
}