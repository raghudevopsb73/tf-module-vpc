resource "aws_vpc" "main" {
  cidr_block         = var.cidr_block
  enable_dns_support = true
  tags = merge({
    Name = "${var.env}-vpc"
    },
  var.tags)
}

module "subnets" {
  source = "./subnets"

  for_each    = var.subnets
  cidr_block  = each.value["cidr_block"]
  subnet_name = each.key

  vpc_id = aws_vpc.main.id

  env  = var.env
  tags = var.tags
  az   = var.az
}

resource "aws_vpc_peering_connection" "peer" {
  peer_vpc_id = aws_vpc.main.id
  vpc_id      = var.default_vpc_id
  auto_accept = true
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = merge({
    Name = "${var.env}-igw"
    },
  var.tags)
}

resource "aws_route" "route-igw" {
  route_table_id         = module.subnets["public"].route_table_ids
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_eip" "ngw" {
  domain = "vpc"
}

resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.ngw.id
  subnet_id     = lookup(lookup(module.subnets, "public", null), "subnet_ids", null)[0]

  tags = merge({
    Name = "${var.env}-ngw"
    },
  var.tags)
}

resource "aws_route" "route-ngw" {
  count                  = length(local.private_route_table_ids)
  route_table_id         = element(local.private_route_table_ids, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.ngw.id
}

resource "aws_route" "peer-route" {
  count                     = length(local.all_route_table_ids)
  route_table_id            = element(local.all_route_table_ids, count.index)
  destination_cidr_block    = "172.31.0.0/16"
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}

resource "aws_route" "default-vpc-apeer-route" {
  route_table_id            = var.default_vpc_rt
  destination_cidr_block    = var.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}
