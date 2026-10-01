# Configure the AWS Provider
provider "aws" {
  region = var.region
  profile = var.profile
}

# Cria uma VPC
resource "aws_vpc" "vpc_app" {
  cidr_block = "10.0.8.0/24"
  tags = var.tags
}

resource "aws_route_table" "saida_internet" {
  vpc_id = aws_vpc.vpc_app.id
  tags = var.tags

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc_app.id
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.subnet_app.id
  route_table_id = aws_route_table.saida_internet.id
}

# Criação da Subnet dentro da VPC (obrigatório para a instância)
resource "aws_subnet" "subnet_app" {
  vpc_id            = aws_vpc.vpc_app.id
  cidr_block        = "10.0.8.0/24" # Precisa caber dentro do CIDR da VPC
  availability_zone = "us-east-1a"

  tags = var.tags
}

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


### Criar uma instancia ec2, usando a vpc acima

#USAR O CODIGO ABAIXO CASO NÃO SOUBERMOS O AMI-ID
#data "aws_ami" "ubuntu" {
#  most_recent = true
#
#  filter {
#    name   = "name"
#    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-resolute-26.04-amd64-server-20260604*"]
#  }
#
#  filter {
#    name   = "virtualization-type"
#    values = ["hvm"]
#  }
#
#  owners = ["099720109477"] # Canonical
#}

resource "aws_instance" "example" {
  #ami           = data.aws_ami.ubuntu.id  #aqui se quiser pegar o id da ami encontrada no bloco anterior
  ami           = "ami-0b6d9d3d33ba97d99"
  instance_type = "t3.micro"
  count = 2
  subnet_id = aws_subnet.subnet_app.id
  key_name = "alex-key"
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.security_group_web-ssh.id]
  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y nginx
              systemctl start nginx
              systemctl enable nginx
              echo "<h1>Instancia ${count.index + 1} - online via Terraform!</h1>" > /var/www/html/index.html
              EOF

  tags = {
    Name = "InstanciaCriada-Terraform-${count.index + 1}"  
  }
}

output "ips_publicos" {
  description = "Lista dos IPs das instâncias criadas"
  value = aws_instance.example[*].public_ip  
}

#CRIAR UM BUCKET S3
#
#resource "aws_s3_bucket" "bucket1" {
#  bucket = "bucket-thinkpad-terraform"
#  tags = {
#    CreatedAt        = "20260930"
#    ManagedBy        = "Terraform"
#  }
#}
#
#resource "aws_s3_bucket_versioning" "versioning_bucket1" {
#  bucket = aws_s3_bucket.bucket1.id
#  versioning_configuration {
#    status = "Enabled"
#  }
#}
