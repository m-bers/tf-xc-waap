
provider "aws" {
  shared_credentials_file = var.aws_credentials_path
  profile                 = "default"
  region                  = "us-west-2"
}

resource "aws_vpc" "main-vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  enable_classiclink   = "false"
  instance_tenancy     = "default"
}

resource "aws_subnet" "prod-subnet-public-1" {
  vpc_id                  = aws_vpc.main-vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "us-west-2a"
}

resource "aws_internet_gateway" "prod-igw" {
  vpc_id = aws_vpc.main-vpc.id
}

resource "aws_route_table" "prod-public-crt" {
  vpc_id = aws_vpc.main-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.prod-igw.id
  }
  tags = {
    Name = "prod-public-crt"
  }
}

resource "aws_route_table_association" "prod-crta-public-subnet-1" {
  subnet_id      = aws_subnet.prod-subnet-public-1.id
  route_table_id = aws_route_table.prod-public-crt.id
}

resource "aws_security_group" "ssh-allowed" {
  vpc_id = aws_vpc.main-vpc.id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8080
    to_port     = 8083
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "aws-key" {
  key_name   = "aws-key"
  public_key = file(var.public_key_path)
}

resource "aws_instance" "arcadia-server" {
  ami           = "ami-0c21533018816e490"
  instance_type = "t2.micro"
  tags = {
    Name = "arcadia-server"
  }
  subnet_id              = aws_subnet.prod-subnet-public-1.id
  vpc_security_group_ids = ["${aws_security_group.ssh-allowed.id}"]
  key_name               = aws_key_pair.aws-key.id
  provisioner "file" {
    source      = "scripts/arcadia.sh"
    destination = "/tmp/arcadia.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/arcadia.sh",
      "sudo /tmp/arcadia.sh"
    ]
  }
  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ubuntu"
    private_key = file("${var.private_key_path}")
  }
}

resource "aws_instance" "juice-shop-server" {
  ami           = "ami-0c21533018816e490"
  instance_type = "t2.micro"
  tags = {
    Name = "juice-shop-server"
  }
  subnet_id              = aws_subnet.prod-subnet-public-1.id
  vpc_security_group_ids = ["${aws_security_group.ssh-allowed.id}"]
  key_name               = aws_key_pair.aws-key.id
  provisioner "file" {
    source      = "scripts/juice-shop.sh"
    destination = "/tmp/juice-shop.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/juice-shop.sh",
      "sudo /tmp/juice-shop.sh"
    ]
  }
  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ubuntu"
    private_key = file("${var.private_key_path}")
  }
}