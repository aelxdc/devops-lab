### Cria uma security group
resource "aws_security_group" "security_group_web-ssh" {
  name = "accesso-web-ssh"
  description = "libera os acessos web e ssh"
  vpc_id = aws_vpc.vpc_app.id
  
  ingress {
    description = "Acesso http"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [var.acesso_geral]
  }

  ingress {
    description = "Acesso https"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = [var.acesso_geral]
  }

    ingress {
    description = "Acesso ssh"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [var.ip_casa]
  }
    egress {
      description = "Libera trafego de saida"
      from_port = 0
      to_port = 0
      protocol = -1 #Significa todos os protocolos
      cidr_blocks = [ "0.0.0.0/0" ]
  }
  tags = var.tags
  
}