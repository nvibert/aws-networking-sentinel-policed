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
  region  = "us-west-2"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"


  tags = {
    Name = "nico-vibert-change-60"
  }

}


resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "nico-vibert-sg-allow-tls"
  }
}

resource "aws_security_group" "allow_all" {
  name        = "not_allow_all"
  description = "Allow All inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow Ingress All"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/8"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "nico-vibert-sg-allow-all"
  }
}



resource "aws_vpn_gateway" "vpn_gateway" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "nico-vibert-vpn-gateway"
  }
}

resource "aws_customer_gateway" "customer_gateway" {
  bgp_asn    = 65000
  ip_address = "172.0.0.1"
  type       = "ipsec.1"
}

resource "aws_vpn_connection" "main" {
  vpn_gateway_id                  = aws_vpn_gateway.vpn_gateway.id
  customer_gateway_id             = aws_customer_gateway.customer_gateway.id
  type                            = "ipsec.1"
  static_routes_only              = true
  tunnel1_phase1_dh_group_numbers = ["2"]
}
