resource "aws_nat_gateway" "fargate" {
  allocation_id = aws_eip.name.id
  subnet_id = tolist(data.aws_subnets.subnets.ids)[1]
  tags = {
    Name = "fargate-execution"
  }
}

resource "aws_route_table" "example" {
  vpc_id = data.aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.fargate.id
  }

  tags = {
    Name = "fargate-pods"
  }
}

resource "aws_eip" "name" {
    tags = {
      Name = "fargate-eip"
    }
}

resource "aws_route_table_association" "name" {
  subnet_id = data.aws_subnet.private.id
  route_table_id = aws_route_table.example.id
}