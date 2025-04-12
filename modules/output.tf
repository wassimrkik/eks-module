output "subnets" {
  value = data.aws_subnets.subnets.ids
}

output "raw_subnet_data" {
  value = data.aws_subnets.subnets
}

output "this" {
  value = aws_eks_cluster.anp.arn
}

output "addon_names" {
  value = {
    for k, v in data.aws_eks_addon_version.this :
    k => v.addon_name
  }
}

output "ep" {
  value = aws_eks_cluster.anp.endpoint
}

