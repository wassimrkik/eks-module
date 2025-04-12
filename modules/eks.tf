resource "aws_eks_cluster" "anp" {
  name = "ANP-${var.cluster_name}"

  access_config {
    authentication_mode = "API"
  }

  role_arn = module.IAM_role_eks.role_arn
  version  = "1.32"

  vpc_config {
    endpoint_public_access = false
    endpoint_private_access = true
    subnet_ids = [
      tolist(data.aws_subnets.subnets.ids)[0],
      tolist(data.aws_subnets.subnets.ids)[1],
    ]
  }
  
  depends_on = [ module.IAM_role_eks ]
}


######################### NEEDS SSL CERTIFICATES TO BE CONFIGURED ON NODE GROUP##############################################################################################################
############################## CREATE ACCESS ENTRY FOR POD ASSOCIATION ON EKS CLUSTER #############################################
# resource "aws_eks_addon" "this" {
#   for_each = {for k, v in var.cluster_addons : k => v }
#   cluster_name = aws_eks_cluster.anp.name
#   addon_name = try(each.value.name, each.key)
#   addon_version        = coalesce(try(each.value.addon_version, null), data.aws_eks_addon_version.this[each.key].version)
#   configuration_values = try(each.value.configuration_values, null)
#   pod_identity_association {
#     role_arn = each.key == "aws-ebs-csi-driver" ? "arn:aws:iam::698178790353:role/App_AmazonEKSPodIdentityAmazonEBSCSIDriverRole" : null
#     service_account = "ebs-csi-controller-sa"
#   }
# }
####################################################################################################################################################################################
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

resource "aws_eks_addon" "ebs_csi_driver" {
  for_each = {
    for k, v in var.cluster_addons :
    k => v if k == "aws-ebs-csi-driver"
  }

  cluster_name             = aws_eks_cluster.anp.name
  addon_name               = each.key
  addon_version            = coalesce(try(each.value.addon_version, null), data.aws_eks_addon_version.this[each.key].version)
  configuration_values     = try(each.value.configuration_values, null)
  ################# service account for ebs csi driver #################
  # TO DO #### CREATE IAM ROLE USING TERRAFORM #####
  ############### NEEDS NODE GROUP IAM ROLE TO HAVE EBSCSIDRIVER policy ############################################################
  service_account_role_arn = each.key == "aws-ebs-csi-driver" ? aws_iam_role.eks_sa_role.arn : null
  lifecycle {
    create_before_destroy = false
  }
}


########## to be added, OIDC association + iam role creation #####

# module "ebs_role_iam" {
#   source = "./module"
#   role_name = "EBS-CSI-${aws_eks_cluster.anp.name}"
#   policy_json = data.aws_iam_policy_document.EBS-CSI.json
#   service = "sts"
  
# }

# resource "aws_iam_policy_attachment" "ebs-csi-attachment" {
#   name = "EBSCSI-Driver"
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
#   roles = [module.ebs_role_iam.role_name]
# }
