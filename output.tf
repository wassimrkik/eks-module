# output "test" {
#   value = module.eks.this
# }
# output "subnets" {
#   value = module.eks.raw_subnet_data
# }

output "addon_names" {
  value = module.eks.addon_names
}

output "this" {
  value = "this is the endoint to use ${module.eks.ep}"
}