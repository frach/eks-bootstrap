variable "account_id" {
  type = string
}

variable "name_prefix" {
  type = string
}

variable "public_subnets" {
  type = list(object({
    az_suffix = string
    cidr      = string
  }))
}

variable "region" {
  type = string
}

variable "vpc_cidr" {
  type = string
}
