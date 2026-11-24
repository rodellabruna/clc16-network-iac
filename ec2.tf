/*
# 1. Busca automaticamente a AMI mais recente do Amazon Linux 2023
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

# 2. Security Group liberando HTTP (80) e SSH (22)
resource "aws_security_group" "web_sg" {
  name        = "allow_http_ssh"
  description = "Libera trafego HTTP na porta 80 e SSH na porta 22"
  vpc_id      = aws_vpc.clc_vpc.id # Ajuste o nome se sua VPC tiver outro nome no Terraform

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Por seguranca, voce pode trocar pelo seu IP publico
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg-web-apache"
  }
}

# 3. Instancia EC2 na subnet publica 1a
resource "aws_instance" "web_server" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t3.micro"                     # Elegivel para o Free Tier
  subnet_id                   = aws_subnet.public_subnet_1a.id # Ajuste para o nome exato da sua subnet 1a
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  associate_public_ip_address = true

  user_data_replace_on_change = true

  # Script executado na inicializacao para instalar e iniciar o Apache
  user_data = <<-EOF
#!/bin/bash
dnf update -y
dnf install -y httpd
systemctl enable --now httpd
cat <<'HTML' > /var/www/html/index.html
<!DOCTYPE html>
<html lang="pt-BR">
<head><meta charset="utf-8"><title>CLC 16</title></head>
<body><h1>CHEGUEI ATÉ AQUI - Rosana Della Bruna - CLC 16</h1></body>
</html>
HTML
EOF


  tags = {
    Name = "ec2-web_tf"
  }
}

# 4. Exibe o IP publico no terminal apos aplicar
output "ec2_public_ip" {
  description = "IP publico para acessar o Apache no navegador"
  value       = aws_instance.web_server.public_ip
}
*/