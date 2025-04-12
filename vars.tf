variable "awsregion" {
  type    = string
  default = "eu-west-1"
}

variable "desired_size" {
  default = 1
  type    = number
}
variable "max_size" {
  default = 2
  type    = number
}
variable "min_size" {
  default = 1
  type    = number
}

variable "env" {
  type    = string
  default = "dev"
}

variable "private" {
  type     = bool
  nullable = true
  default  = false
}

variable "public" {
  type     = bool
  nullable = true
  default  = false
}