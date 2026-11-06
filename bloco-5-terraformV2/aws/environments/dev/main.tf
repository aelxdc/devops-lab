## os blocos moved abaixo, faz uso do terraform move{}
#moved {
#  from = aws_instance.ec2create
#  to   = module.app_cluster.aws_instance.ec2create
#}
#
#moved {
#  from = aws_security_group.security_group_web_ssh
#  to   = module.app_cluster.aws_security_group.security_group_web_ssh
#}


##blocos import e resource abaixo, servem para importar, por exemplo, um security group legado,
##que pode ter sido criado diretamente no console da aws, para o terraform e passa a ser
##controlado por ele
#Bloco de importação
#import {
#  to = aws_security_group.sg_legado
#  id = "sg-0abc12345def67890" # ID do recurso existente na AWS
#}

#Definição do recurso correspondente no código
#resource "aws_security_group" "sg_legado" {
#  name        = "security-group-manual"
#  description = "SG criado via console AWS incorporado ao Terraform"
#  vpc_id      = module.vpc.vpc_id
#}

#Módulo oficial consumido do Registry
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