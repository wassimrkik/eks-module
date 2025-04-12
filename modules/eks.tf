resource "aws_eks_cluster" "anp" {
  name = "ANP-${var.cluster_name}"

  access_config {
    authentication_mode = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }
  role_arn = aws_iam_role.this.arn
  version  = "1.32"

  vpc_config {
    endpoint_public_access = var.public
    endpoint_private_access = try(var.private, null)
    subnet_ids = [
      tolist(data.aws_subnets.subnets.ids)[0],
      tolist(data.aws_subnets.subnets.ids)[1],
      tolist(data.aws_subnets.subnets.ids)[2],
      data.aws_subnet.private.id,
    ]
  }
  
  depends_on = [ aws_iam_role.this ]
}


data "aws_eks_addon_version" "this" {
  for_each = { for k, v in var.cluster_addons : k => v }
  addon_name         = try(each.value.name, each.key)
  kubernetes_version =  aws_eks_cluster.anp.version
  most_recent = try(each.value.most_recent, null)
}

resource "aws_eks_addon" "default_addons" {
  for_each = {
    for k, v in var.cluster_addons :
    k => v if k != "aws-ebs-csi-driver"
  }

  cluster_name             = aws_eks_cluster.anp.name
  addon_name               = each.key
  addon_version            = coalesce(try(each.value.addon_version, null), data.aws_eks_addon_version.this[each.key].version)
  configuration_values     = try(each.value.configuration_values, null)
  lifecycle {
    create_before_destroy = false
  }
}


resource "aws_eks_fargate_profile" "fargate" {
  cluster_name = aws_eks_cluster.anp.name
  fargate_profile_name = "fargate-exec"
  subnet_ids = [data.aws_subnet.private.id]
  pod_execution_role_arn = aws_iam_role.fargate.arn
  selector {
    namespace = "default"
  }
  selector {
    namespace = "kube-system"
  }
}

resource "aws_iam_role" "fargate" {
  name = "App_fargate-eks"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "eks-fargate-pods.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "example-AmazonEKSFargatePodExecutionRolePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  role       = aws_iam_role.fargate.name
}