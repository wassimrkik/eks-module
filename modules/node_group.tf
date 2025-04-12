resource "aws_eks_node_group" "example" {
  cluster_name    = aws_eks_cluster.anp.name
  node_group_name = "example"
  node_role_arn   = module.node_group_role.role_arn
  subnet_ids      = [tolist(data.aws_subnets.subnets.ids)[0],tolist(data.aws_subnets.subnets.ids)[1]]

  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }

  update_config {
    max_unavailable = 1
  }
}

################# ADD EBSCSI DRIVER POLICY  ##################
module "node_group_role" {
  source = "./module"
  role_name = "ANP-EKS-NODEGROUP"
  service = "ec2"
  policy_json = data.aws_iam_policy_document.ANP-EKS-nodegroup.json
}

resource "aws_iam_policy_attachment" "node-group-attachment" {
  name = "EBSCSI-Driver"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  roles = [module.node_group_role.role_name]
}

data "aws_iam_policy_document" "ANP-EKS-nodegroup" {
  statement {
    actions = [
                "ec2:DescribeInstances",
                "ec2:DescribeInstanceTypes",
                "ec2:DescribeRouteTables",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeSubnets",
                "ec2:DescribeVolumes",
                "ec2:DescribeVolumesModifications",
                "ec2:DescribeVpcs",
                "eks:DescribeCluster",
                "eks-auth:AssumeRoleForPodIdentity",
                "ec2:AttachVolume",
                "ec2:CreateVolume",
                "ec2:DeleteVolume",
                "ec2:DescribeVolumes",
                "ec2:ModifyVolume",
                "ec2:DetachVolume",
                "ec2:DescribeAvailabilityZones",
                "ec2:DescribeInstances",
                "ec2:DescribeVolumeStatus",
                "ec2:DescribeVolumeTypes",
                "ec2:DescribeRegions"
    ]
    resources = ["*"]
  }
  statement {
    actions = [
                "ec2:AssignPrivateIpAddresses",
                "ec2:AttachNetworkInterface",
                "ec2:CreateNetworkInterface",
                "ec2:DeleteNetworkInterface",
                "ec2:DescribeInstances",
                "ec2:DescribeTags",
                "ec2:DescribeNetworkInterfaces",
                "ec2:DescribeInstanceTypes",
                "ec2:DescribeSubnets",
                "ec2:DetachNetworkInterface",
                "ec2:ModifyNetworkInterfaceAttribute",
                "ec2:UnassignPrivateIpAddresses"
    ]
    resources = ["*"]
  }
  statement {
    actions = [
        "ec2:CreateTags"
    ]
    resources = ["arn:aws:ec2:*:*:network-interface/*"]
  }
  statement {
    actions = [
        "ecr:GetAuthorizationToken",
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetDownloadUrlForLayer",
                "ecr:GetRepositoryPolicy",
                "ecr:DescribeRepositories",
                "ecr:ListImages",
                "ecr:DescribeImages",
                "ecr:BatchGetImage",
                "ecr:GetLifecyclePolicy",
                "ecr:GetLifecyclePolicyPreview",
                "ecr:ListTagsForResource",
                "ecr:DescribeImageScanFindings"
    ]
    resources = ["*"]
  }
}
