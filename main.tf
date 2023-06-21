resource "aws_vpc" "main" {
  cidr_block         = var.cidr_block
  enable_dns_support = true
  tags = merge({
    Name = "${var.env}-vpc"
    },
  var.tags)
}

resource "aws_subnet" "main" {
  count      = length(var.web_subnet_cidr_block)
  vpc_id     = aws_vpc.main.id
  cidr_block = element(var.web_subnet_cidr_block, count.index)

  tags = merge({
    Name = "${var.env}-web-subnet"
    },
  var.tags)
}

