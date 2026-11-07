# Find the latest available Amazon Linux 2 AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Bastion server in public subnet
resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.amazon_linux_2.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public_1.id
  vpc_security_group_ids      = [aws_security_group.bastion.id]
  key_name                    = var.key_name
  associate_public_ip_address = true

  tags = {
    Name = "startuptech-bastion"
  }
}

# Backend server in private subnet
resource "aws_instance" "backend" {
  ami                         = data.aws_ami.amazon_linux_2.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.private_1.id
  vpc_security_group_ids      = [aws_security_group.backend.id]
  key_name                    = var.key_name
  associate_public_ip_address = false

  user_data = file("${path.module}/../user_data/backend_setup.sh")

  tags = {
    Name = "startuptech-backend"
  }
}

# MongoDB server in private subnet
resource "aws_instance" "mongodb" {
  ami                         = data.aws_ami.amazon_linux_2.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.private_2.id
  vpc_security_group_ids      = [aws_security_group.mongodb.id]
  key_name                    = var.key_name
  associate_public_ip_address = false

  user_data = file("${path.module}/../user_data/mongodb_setup.sh")

  tags = {
    Name = "startuptech-mongodb"
  }
}

# Elastic IP for Bastion
resource "aws_eip" "bastion" {
  domain = "vpc"

  instance = aws_instance.bastion.id

  tags = {
    Name = "startuptech-bastion-eip"
  }
}