
module "efs_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.9.0"

  name        = "${var.name_prefix}-platform-efs-sg"
  description = "Security group dedicated to EFS mount targets."
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.name_prefix}-efs-sg"
  }

  ingress_with_cidr_blocks = [
    {
      from_port   = 2049
      to_port     = 2049
      protocol    = "tcp"
      description = "Ingress NFS traffic"
      cidr_blocks = "10.0.0.0/16"
    }
  ]
}

resource "aws_efs_file_system" "main" {
  creation_token = "${var.name_prefix}-efs"

  tags = {
    Name = "${var.name_prefix}-efs"
  }
}

resource "aws_efs_mount_target" "main" {
  file_system_id  = aws_efs_file_system.main.id
  subnet_id       = aws_subnet.main_publics["10.0.0.0/24"].id
  security_groups = [module.efs_sg.security_group_id]
}

# resource "aws_efs_file_system_policy" "main" {
#   file_system_id = aws_efs_file_system.main.id

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Id      = "efs_eks_policy_of_filesystem"
#     Statement = [
#       {
#         "Sid"    = "AllowWriteForAllAWSPrincipals",
#         "Effect" = "Allow",
#         "Action" = [
#           "elasticfilesystem:ClientRootAccess",
#           "elasticfilesystem:ClientWrite",
#           "elasticfilesystem:ClientMount"
#         ]
#         "Resource"  = aws_efs_file_system.main.arn,
#         "Principal" = "*"
#         "Condition" = {
#           "Bool" : {
#             "elasticfilesystem:AccessedViaMountTarget" : "true"
#           }
#         }
#       },
#       {
#         "Sid"       = "DenyRemovalOfElasticFileSystem",
#         "Effect"    = "Deny",
#         "Action"    = "elasticfilesystem:DeleteFileSystem",
#         "Resource"  = aws_efs_file_system.main.arn,
#         "Principal" = "*"
#       }
#     ]
#   })
# }