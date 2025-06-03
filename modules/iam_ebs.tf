resource "aws_iam_openid_connect_provider" "oidc_provider" {
  url = aws_eks_cluster.anp.identity[0].oidc[0].issuer

  client_id_list = [
    "sts.amazonaws.com",         # Required audience for EKS
  ]

}

######################################################
# 3. IAM Role for Kubernetes Service Account (with sub)
######################################################

resource "aws_iam_role" "eks_sa_role" {
  name = "App_eks-irsa-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = aws_iam_openid_connect_provider.oidc_provider.arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "${replace(aws_iam_openid_connect_provider.oidc_provider.url, "https://", "")}:aud" = "sts.amazonaws.com",
            "${replace(aws_iam_openid_connect_provider.oidc_provider.url, "https://", "")}:sub" = "system:serviceaccount:kube-system:ebs-csi-controller-sa"
          }
        }
      }
    ]
  })

  tags = {
    Name = "eks-irsa-role"
  }
}

resource "aws_iam_policy_attachment" "ebs-csi-attachment" {
  name = "EBSCSI-Driver"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  roles = [aws_iam_role.eks_sa_role.name]
}