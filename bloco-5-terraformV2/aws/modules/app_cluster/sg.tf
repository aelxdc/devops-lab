resource "aws_security_group" "security_group_web_ssh" {
  name        = "${var.name_instance}-sg"
  description = "Libera acessos web e ssh"
  vpc_id      = var.vpc_id

  ingress {
    description = "Acesso HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.acesso_geral]
  }

  ingress {
    description = "Acesso HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.acesso_geral]
  }

  ingress {
    description = "Acesso SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ip_casa]
  }

  egress {
    description = "Trafego de saida geral"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}