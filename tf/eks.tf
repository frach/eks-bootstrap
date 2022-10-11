module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 18.28.0"

  create = !var.eks_disabled

  cluster_name    = "${var.name_prefix}-eks-cluster"
  cluster_version = var.eks_cluster_version

  # Networking connectivity
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true
  cluster_security_group_name     = "${var.name_prefix}-eks-cluster-sg"
  cluster_security_group_additional_rules = {
    admin_access = {
      description = "Admin ingress to Kubernetes API from everywhere"
      cidr_blocks = ["0.0.0.0/0"]
      protocol    = "tcp"
      from_port   = 443
      to_port     = 443
      type        = "ingress"
    }
    recommended_ephemeral_ports_egress = {
      description                = "Outbound traffic from Control Plane to all the Cluster Nodes"
      protocol                   = "tcp"
      from_port                  = 1025
      to_port                    = 65535
      type                       = "egress"
      source_node_security_group = true
    }
  }

  node_security_group_additional_rules = {
    all_ports_ingress_between_nodes = {
      description = "Allow all incomming traffic from other Cluster Nodes"
      protocol    = -1
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    all_ports_egress_between_nodes = {
      description = "Allow all outgoing traffic to the other Cluster Nodes"
      protocol    = -1
      from_port   = 0
      to_port     = 0
      type        = "egress"
      self        = true
    }
    ephemeral_ports_ingress_from_control_plane = {
      description                   = "Allow incomming ephemeral ports from the Control Plane"
      protocol                      = "tcp"
      from_port                     = 1025
      to_port                       = 65535
      type                          = "ingress"
      source_cluster_security_group = true
    }
    # game2048_ingress_from_everywhere = {
    #   description = "Allow incomming 32048 traffic from Everywhere"
    #   protocol    = "tcp"
    #   from_port   = 32048
    #   to_port     = 32048
    #   type        = "ingress"
    #   cidr_blocks = ["0.0.0.0/0"]
    # }
    http_ingress_from_everywhere = {
      description = "Allow incomming HTTP traffic from Everywhere"
      protocol    = "tcp"
      from_port   = 80
      to_port     = 80
      type        = "ingress"
      cidr_blocks = ["0.0.0.0/0"]
    }
    https_ingress_from_everywhere = {
      description = "Allow incomming HTTPS traffic from Everywhere"
      protocol    = "tcp"
      from_port   = 443
      to_port     = 443
      type        = "ingress"
      cidr_blocks = ["0.0.0.0/0"]
    }
    nfs_ports_egress_to_efs_sg = {
      description              = "Allow outgoing NFS ports to the EFS Security Group"
      protocol                 = "tcp"
      from_port                = 2049
      to_port                  = 2049
      type                     = "egress"
      source_security_group_id = module.efs_sg.security_group_id
    }
  }

  # IAM configs
  create_iam_role = false
  iam_role_arn    = aws_iam_role.eks_cluster_service.arn

  # Network configs
  subnet_ids = [for subnet in aws_subnet.main_publics : subnet.id]
  vpc_id     = aws_vpc.main.id

  # Default configs for eks_managed_node_groups
  eks_managed_node_group_defaults = {
    create_iam_role = false
    iam_role_arn    = aws_iam_role.default_worker.arn
  }

  eks_managed_node_groups = {
    default = {
      name            = "${var.name_prefix}-eks-nodegroup-default"
      use_name_prefix = false

      min_size     = 1
      max_size     = 3
      desired_size = 1

      instance_types = var.instance_types
      capacity_type  = "ON_DEMAND"

      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            delete_on_termination = true
            encrypted             = false
            volume_size           = 10
            volume_type           = "gp3"
          }
        }
      }

      labels = {}
      taints = []

      update_config = {
        max_unavailable_percentage = 50
      }

      tags = {
        "k8s.io/cluster-autoscaler/enabled"                                  = "true"
        "k8s.io/cluster-autoscaler/${var.name_prefix}-eks-nodegroup-default" = "owned"
      }
    }
  }
}
