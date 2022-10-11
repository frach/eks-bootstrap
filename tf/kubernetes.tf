data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id


  depends_on = [null_resource.wait_for_cluster]
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id

  depends_on = [null_resource.wait_for_cluster]
}

provider "helm" {
  kubernetes {
    config_context         = "eks-${terraform.workspace}"
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

provider "kubectl" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
}

resource "null_resource" "wait_for_cluster" {
  depends_on = [module.eks.cluster_id]

  provisioner "local-exec" {
    command     = "for i in `seq 1 60`; do if `command -v wget > /dev/null`; then wget --no-check-certificate -O - -q $ENDPOINT/healthz >/dev/null && exit 0 || true; else curl -k -s $ENDPOINT/healthz >/dev/null && exit 0 || true;fi; sleep 5; done; echo TIMEOUT && exit 1"
    interpreter = ["/bin/sh", "-c"]
    environment = {
      ENDPOINT = module.eks.cluster_endpoint
    }
  }
}


# -----------------------------#
#           H E L M           #
# -----------------------------#
resource "helm_release" "lb_controller" {
  name = "aws-load-balancer-controller"

  namespace  = "kube-system"
  repository = "https://aws.github.io/eks-charts"

  chart = "aws-load-balancer-controller"

  values = [
    templatefile("helm_values/lb-controller.yaml", { aws_region = var.region, clusterName = "${var.name_prefix}-eks-cluster" })
  ]
}


#-----------------------------#
#      M A N I F E S T S      #
#-----------------------------#
locals {
  manifests_template_vars = {
    aws_account_id   = var.account_id
    efs_main_id      = aws_efs_file_system.main.id
    eks_cluster_name = module.eks.cluster_id
    hosted_zone_id   = aws_route53_zone.public.zone_id
    name_prefix      = var.name_prefix
    public_domain    = var.hosted_zone_name
  }
  manifests = [
    "eks_aws_auth.yaml",
    "eks_lb_controller.yaml",
    "eks_external_dns.yaml",
    "eks_cluster_autoscaler.yaml",
    "eks_efs.yaml"
  ]
}

# Because kubectl provider is not smart enough to wait for the EKS cluster, we need to put it into the module and add "depends_on"
module "bootstrap_manifests" {
  source   = "./bootstrap"
  for_each = toset(local.manifests)

  eks_cluster_id = module.eks.cluster_id
  template_vars  = local.manifests_template_vars
  manifest_path  = "${path.module}/../k8s/${each.key}"

  depends_on = [null_resource.wait_for_cluster]
}
