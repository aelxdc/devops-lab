variable "region" {
    description = "Define a região da AWS"
    default = "us-east-1"
  
}
variable "profile" {
    description = "Define a profile da conta a ser usada para acessar a AWS"
    default = "tf-thinkpad-almoreira"
  
}

variable "ip_casa" {
  description = "Ip fixo local"
  default = "201.33.248.238/32"
  
}
variable "acesso_geral" {
  description = "CIDR de acesso geral, aberto"
  default = "0.0.0.0/0"
  
}

variable "tags" {
    type = map(string)
    description = ""
    default = {
      "Project" = "API APP"
      "CreatedAT" = "20260930"
    }
  
}


variable "image_id" {
  default = "ami-0b6d9d3d33ba97d99"
  type = string
  description = "ID da imagem AMI a ser usada no deploy"
  

validation {
    condition     = lenght(var.image_id) > 4 && substr(var.image_id, 0, 4) == "ami-"
    error_message = "ID AMI fora do padrão, favor verificar"
  }
}
