data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "ec2create" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance
  count                       = var.servers
  monitoring                  = true
  subnet_id                   = element(var.subnets, count.index)
  key_name                    = "alex-key"
  associate_public_ip_address = false
  vpc_security_group_ids      = [aws_security_group.security_group_web_ssh.id]

  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y nginx
              systemctl start nginx
              systemctl enable nginx
              echo "<h1>Instancia - ${var.name_instance} - ${count.index + 1} - online via Terraform!</h1>" > /var/www/html/index.html
              EOF

  tags = merge(var.tags, {
    Name = "${var.name_instance}-Terraform-${count.index + 1}"
  })
}