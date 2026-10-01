# Configure the AWS Provider
provider "aws" {
  region = var.region
  profile = var.profile
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
  #subnet_id = aws_subnet.subnet_app.id
  subnet_id = element([aws_subnet.subnet_app.id, aws_subnet.subnet_app2.id], count.index)  ## Usamos o elements para que cada instancia seja criada em uma subnet/ zona diferente
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
