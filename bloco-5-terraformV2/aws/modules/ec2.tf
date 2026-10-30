
#USAR O CODIGO ABAIXO CASO NÃO SOUBERMOS O AMI-ID
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-resolute-26.04-amd64-server*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "ec2create" {
  ami           = data.aws_ami.ubuntu.id  #aqui se quiser pegar o id da ami encontrada no bloco anterior
  instance_type = "t3.micro"
  count = var.servers
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
              echo "<h1>Instancia - ${var.name_instance} - ${count.index + 1} - online via Terraform!</h1>" > /var/www/html/index.html
              EOF

  tags = {
    Name = "${var.name_instance}-Terraform-${count.index + 1}"  
  }
}

