variable "awsregion" {
  type = string
  default = "eu-west-1"
}

variable "desired_size" {
  default = 1
}
variable "max_size" {
  default = 2
}
variable "min_size" {
  default = 1
}

variable "env" {
  type = string
  default = "dev"
}