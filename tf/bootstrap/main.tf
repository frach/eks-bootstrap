data "aws_eks_cluster" "cluster" {
  name = var.eks_cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.eks_cluster_id
}

terraform {
  required_providers {
    kubectl = {
      source = "gavinbunney/kubectl"
    }
  }
}


#-----------------------------#
#      M A N I F E S T S      #
#-----------------------------#
data "kubectl_path_documents" "eks_manifests" {
  pattern = var.manifest_path
  vars    = var.template_vars
}

resource "kubectl_manifest" "eks_bootstrap" {
  # Since there is some bug in "kubectl" provider (https://github.com/gavinbunney/terraform-provider-kubectl/issues/61) we need
  # to make a workaround with "count". Normally, we could use the following lines
  # for_each  = data.kubectl_path_documents.eks_manifests.manifests
  # yaml_body = each.value
  count = length(flatten(toset(
    [for f in fileset(".", data.kubectl_path_documents.eks_manifests.pattern) : split("\n---\n", file(f))]
  )))
  yaml_body = element(data.kubectl_path_documents.eks_manifests.documents, count.index)
}