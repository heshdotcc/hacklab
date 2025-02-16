provider "aws" {
  region = "us-west-2"
}

resource "aws_vpc" "wireguard_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_subnet" "wireguard_subnet" {
  vpc_id                  = aws_vpc.wireguard_vpc.id
  cidr_block              = var.subnet_cidr
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "wireguard_gw" {
  vpc_id = aws_vpc.wireguard_vpc.id
}

resource "aws_route_table" "wireguard_rt" {
  vpc_id = aws_vpc.wireguard_vpc.id
}

resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.wireguard_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.wireguard_gw.id
}

resource "aws_route_table_association" "wireguard_rta" {
  subnet_id      = aws_subnet.wireguard_subnet.id
  route_table_id = aws_route_table.wireguard_rt.id
}

resource "aws_iam_role" "ssm_role" {
  name = var.iam_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm_profile" {
  name = var.instance_profile_name
  role = aws_iam_role.ssm_role.name
}

resource "aws_security_group" "wireguard_sg" {
  name        = "wireguard-sg"
  description = "Security group for WireGuard VPN server"
  vpc_id      = aws_vpc.wireguard_vpc.id

  ingress {
    from_port   = var.vpn_port
    to_port     = var.vpn_port
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "wireguard-sg"
  }
}

resource "aws_instance" "wireguard_vps" {
  ami                         = var.ami_id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.wireguard_subnet.id
  vpc_security_group_ids      = [aws_security_group.wireguard_sg.id]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.ssm_profile.name

  user_data = templatefile("${path.module}/userdata.tpl", {
    vpn_cidr        = var.vpn_cidr
    vpn_port        = var.vpn_port
    peer_public_key = var.peer_public_key
    allowed_ips     = var.allowed_ips
    vpc_cidr        = var.vpc_cidr
  })

  tags = {
    Name = "wireguard-vps"
  }
}

resource "aws_vpc_endpoint" "ssm" {
  vpc_id             = aws_vpc.wireguard_vpc.id
  service_name       = "com.amazonaws.${data.aws_region.current.name}.ssm"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = [aws_subnet.wireguard_subnet.id]
  security_group_ids = [aws_security_group.wireguard_sg.id]
}

resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id             = aws_vpc.wireguard_vpc.id
  service_name       = "com.amazonaws.${data.aws_region.current.name}.ssmmessages"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = [aws_subnet.wireguard_subnet.id]
  security_group_ids = [aws_security_group.wireguard_sg.id]
}

resource "aws_vpc_endpoint" "ec2messages" {
  vpc_id             = aws_vpc.wireguard_vpc.id
  service_name       = "com.amazonaws.${data.aws_region.current.name}.ec2messages"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = [aws_subnet.wireguard_subnet.id]
  security_group_ids = [aws_security_group.wireguard_sg.id]
}

data "aws_region" "current" {}

resource "aws_eip" "wireguard_eip" {
  domain = "vpc"
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.wireguard_vps.id
  allocation_id = aws_eip.wireguard_eip.id
}

output "elastic_ip" {
  value       = aws_eip.wireguard_eip.public_ip
  description = "Elastic IP for peers WireGuard endpoint"
}
