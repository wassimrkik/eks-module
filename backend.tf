terraform {
  backend "s3" {
    bucket = "sanofi-chc-emea-anp-terraformstate-dev"
    key = "api/eks.tfstate"
    region = "eu-west-1"
  }
}