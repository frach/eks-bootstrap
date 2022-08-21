locals {
  public_subnets = { for subnet in var.public_subnets : subnet.cidr => subnet }
}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = { Name = "${var.name_prefix}-vpc" }
}


#-----------------------------#
#      INTERNET GATEWAYS      #
#-----------------------------#
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = { Name = "${var.name_prefix}-vpc-igw" }
}


#-----------------------------#
#         NETWORK ACLS        #
#-----------------------------#
resource "aws_network_acl" "main" {
  vpc_id = aws_vpc.main.id

  egress {
    protocol   = "all"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "all"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = { Name = "${var.name_prefix}-vpc-nacl" }
}


#-----------------------------#
#       PUBLIC SUBNETS        #
#-----------------------------#
resource "aws_subnet" "main_publics" {
  for_each = local.public_subnets

  availability_zone       = "${var.region}${each.value.az_suffix}"
  cidr_block              = each.value.cidr
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.main.id

  tags = { Name = "${var.name_prefix}-main-subnet-pub-${each.value.az_suffix}" }
}

resource "aws_route_table" "main_public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = { Name = "${var.name_prefix}-vpc-public-rt" }
}

resource "aws_route_table_association" "main_public" {
  for_each = local.public_subnets

  subnet_id      = aws_subnet.main_publics[each.key].id
  route_table_id = aws_route_table.main_public.id
}


# #-----------------------------#
# #          ROUTE 53           #
# #-----------------------------#
# resource "aws_route53_zone" "private" {
#   name = var.private_hosted_zone_name

#   vpc {
#     vpc_id = aws_vpc.main.id
#   }

#   tags = {
#     Service = var.cost_tags.networking
#   }
# }
