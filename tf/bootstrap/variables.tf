
variable "eks_cluster_id" {
  description = "An ID of the EKS cluster"
  type        = string
}

variable "manifest_path" {
  description = "A path to the manifest YAML file that will be applied to the cluster"
  type        = string
}

variable "template_vars" {
  description = "A dict with values that the manifest will be rendered with"
  type        = any
}