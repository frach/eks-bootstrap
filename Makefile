# "darwin" for macOS, "linux" for Linux
LOCAL_OS := $(shell uname -s | tr A-Z a-z)


# INCLUDES
-include ./Makefile_tf.mk


deploy: tf-apply
destroy: tf-destroy
redeploy: tf-destroy


# EKS stuff
EKS_CLUSTER_NAME = eks-bootstrap-eks-cluster
EKS_CONFIG_FILE = ~/.kube/config
EKS_CONTEXT = priv

eks-update-kubeconfig:
	$(info ==> Updating kube config file ($(EKS_CONFIG_FILE)) with "$(EKS_CONTEXT)" context)
	@aws eks update-kubeconfig --name $(EKS_CLUSTER_NAME) --kubeconfig $(EKS_CONFIG_FILE) --alias $(EKS_CONTEXT) && \
		echo "  --> Local kube config file updated."

deploy-2048:
	kubectl apply -f k8s/2048.yaml
