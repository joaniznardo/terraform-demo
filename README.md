# terraform-demo
plantilla per crear màquines virtuals amb libvirt

0) [run once] install terraform libvirt provider (see 1st link)

1) CHANGE CONTENT in var.tf
2) make create-keypair && make init && make plan && make apply
3) wait till vm completely starts...
4) make metadata

then you can log in with: 
ssh alumne@PUT_OUTPUT_IP -i ./id_rsa
 
basat en:
[RTFM](https://fabianlee.org/2020/02/22/kvm-terraform-and-cloud-init-to-create-local-kvm-resources)
[fabianlee](https://github.com/fabianlee/terraform-libvirt-ubuntu-examples)
[dmacvicar](https://github.com/dmacvicar/terraform-provider-libvirt)
[cloud-init](https://cloudinit.readthedocs.io/en/latest/topics/examples.html)
