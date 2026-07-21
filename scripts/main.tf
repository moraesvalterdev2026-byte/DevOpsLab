# infra/terraform/main.tf

# Bloco de configuração do Terraform.
# Especifica a versão do Terraform e os provedores necessários (AWS e HTTP).
terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.4"
    }
  }
}

# Configura o provedor da AWS, definindo a região onde os recursos serão criados.
provider "aws" {
  region = "us-east-1"
}

# Data source para obter o IP público da máquina que executa o Terraform.
data "http" "my_ip" {
  url = "https://ipv4.icanhazip.com"
}

# Declara o nosso primeiro recurso: uma Virtual Private Cloud (VPC).
# Esta será a rede isolada para a nossa aplicação na AWS.
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "axes-bank-vpc"
  }
}

# Cria uma sub-rede pública dentro da nossa VPC.
# É aqui que nossos recursos, como a instância EC2, ficarão.
resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"

  # Garante que instâncias lançadas nesta sub-rede recebam um IP público.
  map_public_ip_on_launch = true

  tags = {
    Name = "axes-bank-public-subnet"
  }
}

# Cria um Internet Gateway para permitir a comunicação entre a VPC e a internet.
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "axes-bank-igw"
  }
}

# Cria uma tabela de rotas para direcionar o tráfego da sub-rede para a internet.
resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0" # Rota para todo o tráfego de saída.
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "axes-bank-public-rt"
  }
}

# Associa a tabela de rotas à nossa sub-rede pública.
resource "aws_route_table_association" "main" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.main.id
}

# Cria um grupo de segurança (firewall) para a nossa instância EC2.
resource "aws_security_group" "app_sg" {
  name        = "axes-bank-app-sg"
  description = "Allow SSH and App traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22 # Permite acesso SSH
    to_port     = 22
    protocol    = "tcp"
    # Restringe o acesso SSH dinamicamente ao IP da máquina que executa o 'terraform apply'.
    cidr_blocks = ["${chomp(data.http.my_ip.response_body)}/32"]
  }

  ingress {
    from_port   = 3000 # Permite acesso à nossa aplicação Node.js
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "axes-bank-app-sg"
  }
}

# Data source para encontrar a AMI mais recente do Ubuntu 22.04 LTS.
# Isso garante que estamos sempre usando uma imagem atualizada e segura.
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical (dona oficial do Ubuntu)
}

# Cria um par de chaves na AWS para acesso SSH seguro à instância.
# Utiliza a variável definida em 'variables.tf'.
resource "aws_key_pair" "deployer" {
  key_name   = "axes-bank-deployer-key"
  public_key = var.ssh_public_key
}

# Cria a instância EC2 onde a aplicação será executada.
resource "aws_instance" "app_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro" # Ideal para o Free Tier da AWS.
  subnet_id     = aws_subnet.main.id
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  key_name      = aws_key_pair.deployer.key_name

  tags = {
    Name = "axes-bank-app-server"
  }
}