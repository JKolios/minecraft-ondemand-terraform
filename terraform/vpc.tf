resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

resource "aws_default_subnet" "default_az1" {
  availability_zone = format("%sa", var.aws_region)
}

resource "aws_default_subnet" "default_az2" {
  availability_zone = format("%sb", var.aws_region)
}

resource "aws_default_subnet" "default_az3" {
  availability_zone = format("%sc", var.aws_region)
}

resource "aws_security_group" "allow_minecraft_server_port" {
  name        = "minecraft_server_port"
  description = "Allow inbound traffic to the Minecraft server port"
  vpc_id      = aws_default_vpc.default.id

  ingress {
    description      = "Minecraft server port"
    from_port        = 25565
    to_port          = 25565
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "EFS NFS port"
    from_port        = 2049
    to_port          = 2049
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = var.common_tags
}