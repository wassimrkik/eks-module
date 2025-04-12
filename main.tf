module "eks" {
  source = "./modules"
  cluster_name = "kube-${var.env}"
  desired_size = var.desired_size
  min_size = var.min_size
  max_size = var.max_size
  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    aws-ebs-csi-driver = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    # eks-pod-identity-agent = {
    #   most_recent = true
    # }
  }
}