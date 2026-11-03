variable "vpc_id" {
  type        = string
  description = "ID da VPC onde o cluster sera criado"
}

variable "subnets" {
  type        = list(string)
  description = "Lista de IDs das subnets publicas para o ALB e as EC2"
}

variable "servers" {
  type        = number
  description = "Quantidade de instancias EC2 a serem criadas"
  default     = 2
}

variable "instance" {
  type        = string
  description = "Tipo da instância"
  default     = "t3.micro"
}

variable "name_instance" {
  type        = string
  description = "Nome base da aplicacao/instancias"
  default     = "app"
}

variable "ip_casa" {
  type        = string
  description = "IP fixo para liberacao administrativa via SSH"
  default     = "201.33.248.238/32"
}

variable "acesso_geral" {
  type        = string
  description = "CIDR de acesso geral"
  default     = "0.0.0.0/0"
}

variable "tags" {
  type        = map(string)
  description = "Tags padronizadas"
  default = {
    Project   = "API APP"
    ManagedBy = "Terraform"
  }
}