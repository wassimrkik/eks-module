terraform {
  backend "s3" {
    bucket = "infrastructure-backend-ede"
    key    = "eks/eks.tfstate"
    region = "ap-south-1"
  }
}