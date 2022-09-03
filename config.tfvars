# General
account_id = "FILLME"         # TODO: Remove this
name_prefix = "eks-bootstrap"
region = "eu-west-1"

# Networking
public_subnets = [{ az_suffix = "a", cidr = "10.0.0.0/24" }, { az_suffix = "b", cidr = "10.0.1.0/24" }]
vpc_cidr       = "10.0.0.0/16"

# EKS
eks_cluster_version = "1.21"
eks_disabled = false
instance_types = ["t3.small"]
