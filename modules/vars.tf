variable "cluster_addons" {
  type = any
  default = {}
}

variable "desired_size" {
  
}
variable "max_size" {
  
}
variable "min_size" {
  
}

variable "cluster_name" {
  type = string
}

variable "private" {
  type = bool
  nullable = true
  default = false
}

variable "public" {
  type = bool
  nullable = true
  default = false
}