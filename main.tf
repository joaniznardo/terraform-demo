terraform {
  required_version = ">= 0.12"
}

##- Hypervisor

provider "libvirt" {
  uri = "qemu:///system"
}

## exemple de definicio de recursos i dades parametritzat per <nom_projecte> <nom_usuari> <comptador>

## remot
#provider "libvirt" {
#  alias = "server2"
#  uri   = "qemu+ssh://root@192.168.100.10/system"
#}

data "template_file" "user_data" {
  template = "${file("${path.module}/cloud_init.cfg")}"
  vars = {
    hostname = var.nom_host
    fqdn = "${var.nom_host}.${var.nom_domini}"
  }
}

##- tot i que no tinga interfícies estàtiques ho introduim per homogeneitzar
## -> abans < ## data "template_file" "meta_data" {
data "template_file" "network_config" {
  template = "${file("${path.module}/network_config.cfg")}"
}

##- Storage -----------------------------------------------------

# Use CloudInit to add the instance
resource "libvirt_cloudinit_disk" "cloud_init" {
  name = "tf-${var.nom_host}-cloudinit.iso"
#  user_data = "${data.template_file.user_data.rendered}"
  user_data = data.template_file.user_data.rendered
  network_config = data.template_file.network_config.rendered
}

resource "libvirt_volume" "centos7_qcow2" {
  name = "tf-${var.nom_host}-${var.account}-${count.index + 1}.qcow2"
  pool = "default"
  format = "qcow2"
  ##- sempre actualitzat
  #source = "https://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud.qcow2"
  ##- local al compte (possibles duplicats: malbaratament d'espai)
  #source = "../terraform2/CentOS-7-x86_64-GenericCloud.qcow2"
  ##- centralitzat (requereix que un compte administratiu la situe allí)
  #source = "/opt/terraform/images/CentOS-7-x86_64-GenericCloud.qcow2"
  ##- linked clone!!!! estalvia espai - possible perill de que desaparega la base
  ##- genial si se disposa de 4 bases: ubuntu/centos x server/desktop
  ##> alternatiu < base_volume_name = "centos7.qcow2"
  base_volume_name = "centos7.qcow2"
  ##base_volume_name = "CentOS-7-x86_64-GenericCloud.qcow2"
  base_volume_pool = "default"
  ##- ready for multi-instancies
  count = var.nombre_instancies
}

##- networking - pendent-------------------------------------------------
##- https://github.com/dmacvicar/terraform-provider-libvirt/blob/master/examples/v0.12/format/libvirt.tf
#
##- si els requeriments de xarxa requereixen de configuracions complexes
## (i.e. rangs concrets, reserva de hosts, tftp/pxe) aleshores millor definir
## la xarxa fora i comentar aquesta
##
resource "libvirt_network" "net" {
  name      = "tf-${var.nom_host}-${var.account}"
  domain    = var.nom_domini
  mode      = "nat"
  addresses = ["10.0.100.0/24"]
}

##- compute -------------------------------------------------------------

# Define KVM domain to create
resource "libvirt_domain" "dom" {
  name = "tf-${var.nom_host}-${var.account}-${count.index + 1}"
  count = var.nombre_instancies
  memory = "1024"
  vcpu   = 1

  network_interface {
  ##  network_name = "default"
    network_name = "tf-${var.nom_host}-${var.account}"
    mac    = "00:11:22:33:88:${count.index}"
  }

  boot_device {
###-   si cal arrancar per xarxa...
#   dev = ["network","hd"]
    dev = ["hd","network"]
  }

  disk {
    volume_id = element(libvirt_volume.centos7_qcow2.*.id, count.index)
  }

  cloudinit = libvirt_cloudinit_disk.cloud_init.id

  console {
    type = "pty"
    target_type = "serial"
    target_port = "0"
  }

  graphics {
    type = "spice"
    listen_type = "address"
    autoport = true
  }
}

# Output Server IP
output "ip" {
  value = libvirt_domain.dom.*.network_interface.0.addresses
}
