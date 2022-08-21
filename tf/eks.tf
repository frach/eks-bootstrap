# module "eks" {
#   source  = "terraform-aws-modules/eks/aws"
#   version = "~> 18.28.0"

#   create = !var.eks_disabled

#   cluster_name    = "${local.name_prefix}-eks-cluster"
#   cluster_version = var.eks_cluster_config.version

#   # Networking connectivity
#   cluster_endpoint_private_access = contains(["private", "all"], var.eks_cluster_config.access)
#   cluster_endpoint_public_access  = contains(["public", "all"], var.eks_cluster_config.access)
#   cluster_security_group_name     = "${local.name_prefix}-eks-cluster-sg"
#   cluster_security_group_additional_rules = {
#     admin_access = {
#       description = "Admin ingress to Kubernetes API from MNM Poznan office"
#       cidr_blocks = [local.infra.office_aggregated_subnets_cidr]
#       protocol    = "tcp"
#       from_port   = 443
#       to_port     = 443
#       type        = "ingress"
#     }
#     recommended_ephemeral_ports_egress = {
#       description                = "Outbound traffic from Control Plane to all the Cluster Nodes"
#       protocol                   = "tcp"
#       from_port                  = 1025
#       to_port                    = 65535
#       type                       = "egress"
#       source_node_security_group = true
#     }

#   }
#   node_security_group_additional_rules = {
#     all_ports_ingress_between_nodes = {
#       description = "Allow all incomming traffic from other Cluster Nodes"
#       protocol    = -1
#       from_port   = 0
#       to_port     = 0
#       type        = "ingress"
#       self        = true
#     }
#     all_ports_egress_between_nodes = {
#       description = "Allow all outgoing traffic to the other Cluster Nodes"
#       protocol    = -1
#       from_port   = 0
#       to_port     = 0
#       type        = "egress"
#       self        = true
#     }
#     ephemeral_ports_ingress_from_control_plane = {
#       description                   = "Allow incomming ephemeral ports from the Control Plane"
#       protocol                      = "tcp"
#       from_port                     = 1025
#       to_port                       = 65535
#       type                          = "ingress"
#       source_cluster_security_group = true
#     }
#     nfs_ports_egress_to_efs_sg = {
#       description              = "Allow outgoing NFS ports to the EFS Security Group"
#       protocol                 = "tcp"
#       from_port                = 2049
#       to_port                  = 2049
#       type                     = "egress"
#       source_security_group_id = local.infra.efs_security_group_id
#     }
#     smtp_egress_to_everywhere = {
#       description      = "Open SMTP ports 587"
#       protocol         = "tcp"
#       from_port        = 587
#       to_port          = 587
#       type             = "egress"
#       cidr_blocks      = ["0.0.0.0/0"]
#       ipv6_cidr_blocks = ["::/0"]
#     }
#     http_egress_to_everywhere = {
#       description      = "Open HTTP ports 80"
#       protocol         = "tcp"
#       from_port        = 80
#       to_port          = 80
#       type             = "egress"
#       cidr_blocks      = ["0.0.0.0/0"]
#       ipv6_cidr_blocks = ["::/0"]
#     }

#   }

#   # IAM configs
#   create_iam_role = false
#   iam_role_arn    = local.infra.eks_service_role_arn

#   # Network configs
#   subnet_ids = local.eks_subnet_ids                        # TODO
#   vpc_id     = local.infra["${local.short_region}_vpc_id"] # TODO

#   # Default configs for eks_managed_node_groups
#   eks_managed_node_group_defaults = {
#     create_iam_role = false
#     iam_role_arn    = aws_iam_role.default_worker.arn
#   }

#   eks_managed_node_groups = {
#     default = {
#       name            = "${local.name_prefix}-eks-nodegroup-default"
#       use_name_prefix = false

#       min_size     = 1
#       max_size     = 2
#       desired_size = 1

#       instance_types = var.eks_ng_core_config.instance_types # TODO
#       capacity_type  = var.eks_ng_core_config.capacity_type  # TODO

#       block_device_mappings = {
#         xvda = {
#           device_name = "/dev/xvda"
#           ebs = {
#             delete_on_termination = true
#             encrypted             = false
#             volume_size           = var.eks_ng_core_config.root_storage_gb # TODO
#             volume_type           = "gp3"
#           }
#         }
#       }

#       labels = var.eks_ng_core_config.labels
#       taints = var.eks_ng_core_config.taints

#       update_config = {
#         max_unavailable_percentage = 50
#       }

#       tags = {
#         "k8s.io/cluster-autoscaler/enabled" = "FALSE"
#         Service                             = var.eks_cost_tags.core_service
#       }
#     }
#   }

#   tags = {
#     Environment = var.eks_cost_tags.env # TODO
#   }
# }

