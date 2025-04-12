
####################### NAT GW ################## 
#######################@ PRIVATE SUBNET FOR FARGATE PROFILE ###################

data "aws_vpc" "main" {
  filter {
    name = "vpc-id"
    values = [ "vpc-0a5b89cd3ada722fc" ]
  }
}

data "aws_subnets" "subnets" {
  filter {
    name = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
}

data "aws_security_group" "default" {
  name = "default"
  vpc_id = data.aws_vpc.main.id
}

data "aws_caller_identity" "current" {
}


data "aws_region" "current" {
}

locals {
  aws_account_id  = data.aws_caller_identity.current.account_id
  aws_region_name = data.aws_region.current.name
  region_mapping = {
    us-east-1 = "amer"
    eu-west-1 = "emea"
    ap-south-1 = "apac"
  }
}

data "aws_subnet" "private" {
  filter {
    name = "tag:Name"
    values = [ "private" ]
  }
}