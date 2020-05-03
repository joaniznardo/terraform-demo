variable "nom_host" {
  type = string
##  default = "server"
  default = "worker"
}

variable "nom_domini" {
  type = string
  default = "just4fun.edu"
}

variable "nombre_instancies" {
  type = number
  default = 2
## normally for server 
##  default = 1
}

variable "account" {
  type = string
  default = "changeme"
## scalable in multiuser environments
##  default = "joan"
}
