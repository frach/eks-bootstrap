TERRAFORM_EXEC := $(abspath terraform)
TERRAFORM_VERSION := 1.2.7
TERRAFORM_PKG := terraform_$(TERRAFORM_VERSION)_$(LOCAL_OS)_amd64.zip

TERRAFORM_DIR := $(abspath tf)
TERRAFORM_PARAMS := -var-file ../config.tfvars


$(TERRAFORM_EXEC):
	curl https://releases.hashicorp.com/terraform/$(TERRAFORM_VERSION)/$(TERRAFORM_PKG) -o $(TERRAFORM_PKG)
	unzip $(TERRAFORM_PKG)
	chmod +x $(TERRAFORM_EXEC)
	rm -rf $(TERRAFORM_PKG)

#TF_LOG=DEBUG
define tf_action
	$(info ==> terraform $(1) $(2))
	@cd $(TERRAFORM_DIR) && $(TERRAFORM_EXEC) $(1) $(2)
endef


tf-fmt: $(TERRAFORM_EXEC)
	$(call tf_action,fmt,-recursive)

tf-init: $(TERRAFORM_EXEC) tf-fmt
	$(call tf_action,init)

tf-apply: $(TERRAFORM_EXEC) tf-fmt
	$(call tf_action,apply,$(TERRAFORM_PARAMS))

tf-destroy: $(TERRAFORM_EXEC) tf-fmt
	$(call tf_action,destroy,$(TERRAFORM_PARAMS))
