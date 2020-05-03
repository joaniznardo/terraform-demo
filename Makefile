THISDIR := $(notdir $(CURDIR))
PROJECT := $(THISDIR)

##
## - seqüencia completa
##
## make create-keypair && make init && make plan && make apply
##

apply: ## applies this
	terraform apply -auto-approve

init: ## first time
	terraform init

plan: ## check what will happen
	terraform plan

## recreate terraform resources
rebuild: destroy apply

## first setup
runonce: create-keypair init plan apply 

destroy:
	terraform destroy -auto-approve

## create public/private keypair for ssh
create-keypair:
	@echo "THISDIR=$(THISDIR)"
	ssh-keygen -t rsa -b 4096 -f id_rsa -C $(PROJECT) -N "" -q

metadata:
	terraform refresh && terraform output ip

##get-iso:
## 	wget -P ~/Downloads http://releases.ubuntu.com/18.04/ubuntu-18.04.4-live-server-amd64.iso
        
get-image:
        sudo ls /var/lib/libvirt/images/CentOS-7-x86_64-GenericCloud.qcow2 || \
	wget https://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud.qcow2 && \
        sudo mv CentOS-7-x86_64-GenericCloud.qcow2 /var/lib/libvirt/images/CentOS-7-x86_64-GenericCloud.qcow2 

## list make targets
## https://stackoverflow.com/questions/4219255/how-do-you-get-the-list-of-targets-in-a-makefile
list:
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$'


