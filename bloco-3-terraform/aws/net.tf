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

resource "aws_route_table_association" "public_assoc_2" {
  subnet_id      = aws_subnet.subnet_app2.id
  route_table_id = aws_route_table.saida_internet.id
}

# Criação da Subnet dentro da VPC (obrigatório para a instância)
resource "aws_subnet" "subnet_app" {
  vpc_id            = aws_vpc.vpc_app.id
  cidr_block        = "10.0.8.0/25" # Precisa caber dentro do CIDR da VPC
  availability_zone = "${var.region}a"

  tags = var.tags
}

resource "aws_subnet" "subnet_app2" {
  vpc_id            = aws_vpc.vpc_app.id
  cidr_block        = "10.0.8.128/25" # Precisa caber dentro do CIDR da VPC
  availability_zone = "${var.region}b"

  tags = var.tags
}