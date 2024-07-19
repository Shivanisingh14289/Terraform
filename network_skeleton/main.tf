resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.stack_name}/VPC"
  }
}



resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.stack_name}/InternetGateway"
  }
}

# Create EIP for NAT gateway
resource "aws_eip" "main" {
#  vpc = true
  tags = {
    Name = "${var.stack_name}/NATIP"
  }
}
# Create NAT gateway
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.main.id
  subnet_id     = aws_subnet.public[2].id

  tags = {
    Name = "${var.stack_name}/NATGateway"
  }
}

// Public Subnet
resource "aws_subnet" "public" {
  count = length(var.public_subnets)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnets[count.index].cidr_block
  availability_zone       = var.public_subnets[count.index].az
  map_public_ip_on_launch = true

  tags = {
    "kubernetes.io/role/elb" = "1"
    Name                     = "${var.stack_name}/${var.public_subnets[count.index].name}"
  }
}


// Private Subnet

# Create private subnets
resource "aws_subnet" "private" {
  count = length(var.private_subnets)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnets[count.index].cidr_block
  availability_zone = var.private_subnets[count.index].az

  tags = {
    "kubernetes.io/role/internal-elb" = "1"
    Name                              = "${var.stack_name}/${var.private_subnets[count.index].name}"
  }
}

# Create public route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.stack_name}/PublicRouteTable"
  }
}
# Create private route tables
resource "aws_route_table" "private" {
  count = length(var.private_route_tables)

  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.stack_name}/${var.private_route_tables[count.index]}"
  }
}

# Associate public subnets with public route table
resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Associate private subnets with private route tables
resource "aws_route_table_association" "private" {
  count          = length(var.private_subnets)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

resource "aws_route" "nat_gateway_private" {
  count = length(var.private_subnets)

  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main.id
}
