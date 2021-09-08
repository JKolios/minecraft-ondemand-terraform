resource "aws_vpc" "minecraft_ondemand_vpc" {
  cidr_block = var.vpc_cidr
  tags = var.common_tags
}

resource "aws_subnet" "minecraft_ondemand_vpc_subnet_1" {
  vpc_id     = aws_vpc.minecraft_ondemand_vpc.id
  cidr_block = cidrsubnet(var.vpc_cidr, 4, 0)

  tags = var.common_tags
}

resource "aws_subnet" "minecraft_ondemand_vpc_subnet_2" {
  vpc_id     = aws_vpc.minecraft_ondemand_vpc.id
  cidr_block = cidrsubnet(var.vpc_cidr, 4, 1)

  tags = var.common_tags
}

resource "aws_subnet" "minecraft_ondemand_vpc_subnet_3" {
  vpc_id     = aws_vpc.minecraft_ondemand_vpc.id
  cidr_block = cidrsubnet(var.vpc_cidr, 4, 2)

  tags = var.common_tags
}

resource "aws_security_group" "allow_minecraft_server_port" {
  name        = "minecraft_server_port"
  description = "Allow inbound traffic to the Minecraft server port"
  vpc_id      = aws_vpc.minecraft_ondemand_vpc.id

  ingress {
      description      = "Minecraft server port"
      from_port        = 25565
      to_port          = 25565
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