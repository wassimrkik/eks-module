module "eks" {
  source       = "./modules"
  cluster_name = "kube-${var.env}"
  public       = true
  desired_size = var.desired_size
  min_size     = var.min_size
  max_size     = var.max_size
  cluster_addons = {
    kube-proxy = {
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