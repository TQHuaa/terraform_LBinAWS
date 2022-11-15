terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region = "ap-east-1"
}

resource "aws_vpc" "tf_vpc" {
    cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "tf_subnet_private_1" {
  vpc_id = aws_vpc.tf_vpc.id
  availability_zone = "ap-east-1a"
  cidr_block = "10.0.1.0/24"
}

resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Allow HTTP inbound traffic"
  vpc_id      = aws_vpc.tf_vpc.id

  ingress {
    description      = "HTTP from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group" "allow_ssh" {
    name        = "allow_ssh"
    description = "Allow SSH inbound traffic"
    vpc_id      = aws_vpc.tf_vpc.id

    ingress {
        description      = "SSH from VPC"
        from_port        = 22
        to_port          = 22
        protocol         = "tcp"
        cidr_blocks      = ["0.0.0.0/0"]
    }

    egress {
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    } 
}


resource "aws_internet_gateway" "tf_gateway" {
  vpc_id = aws_vpc.tf_vpc.id
}


resource "aws_eip" "VIP_eip" {
  vpc        = true
#  depends_on = [aws_internet_gateway.id]
}



resource "aws_route_table" "private" {
  vpc_id = aws_vpc.tf_vpc.id
}


resource "aws_route_table_association" "tf_rt_a_1" {
  subnet_id = aws_subnet.tf_subnet_private_1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.tf_gateway.id
}

data "aws_iam_policy_document" "instance-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "ec2FullAccess" {
  name = "policy-huatq_2"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["ec2:*"]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}


resource "aws_instance" "LB1" {
  #count = 2

  ami                  = "ami-0ad5e5b79f0def493"
  instance_type        = "t3.micro"
  user_data            = "${file("master_install.sh")}"
  subnet_id              = aws_subnet.tf_subnet_private_1.id
  vpc_security_group_ids = [aws_security_group.allow_http.id, aws_security_group.allow_ssh.id]
  key_name             = "huatq"

  associate_public_ip_address = true
  private_ip                  = "10.0.1.101"
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.LB1.id
  allocation_id = "eipalloc-0b9830cd5739495bc"
}

resource "aws_instance" "LB2" {
  #count = 2

  ami                  = "ami-0ad5e5b79f0def493"
  instance_type        = "t3.micro"
  user_data            = "${file("backup_install.sh")}"
  subnet_id              = aws_subnet.tf_subnet_private_1.id
  vpc_security_group_ids = [aws_security_group.allow_http.id, aws_security_group.allow_ssh.id]
  key_name             = "huatq"

  associate_public_ip_address = true
  private_ip                  = "10.0.1.102"
}


resource "aws_instance" "web1" {
  #count = 2

  ami                  = "ami-0ad5e5b79f0def493"
  instance_type        = "t3.micro"
  user_data            = "${file("app_install.sh")}"
  subnet_id              = aws_subnet.tf_subnet_private_1.id
  vpc_security_group_ids = [aws_security_group.allow_http.id, aws_security_group.allow_ssh.id]
  key_name             = "huatq"

  associate_public_ip_address = true
  private_ip                  = "10.0.1.86"
}


resource "aws_instance" "web2" {
  #count = 2

  ami                  = "ami-0ad5e5b79f0def493"
  instance_type        = "t3.micro"
  user_data            = "${file("app_install.sh")}"
  subnet_id              = aws_subnet.tf_subnet_private_1.id
  vpc_security_group_ids = [aws_security_group.allow_http.id, aws_security_group.allow_ssh.id]
  key_name             = "huatq"

  associate_public_ip_address = true
  private_ip                  = "10.0.1.87"
}