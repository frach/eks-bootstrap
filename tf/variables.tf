variable "account_id" {
  type = string
}

variable "eks_cluster_version" {
  type = string
}

variable "eks_disabled" {
  type = bool
}

variable "hosted_zone_name" {
  type = string
}

variable "instance_types" {
  type = list(string)
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
