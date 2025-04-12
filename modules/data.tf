data "aws_vpc" "main" {
}

data "aws_subnets" "subnets" {
  filter {
    name = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
}

data "aws_security_group" "internet_access" {
  name = "internet-access"
}

data "aws_security_group" "default" {
  name = "default"
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
