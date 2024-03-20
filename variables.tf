variable "key_name" {
  type    = string
  default = "vockey"
}

variable "volume_size" {
  type    = number
  default = 30
}

variable "distro_ec2" {
  type    = bool
  default = true
}

variable "cloud-config-vpn" {
  type    = string
  default = "cloud-config-vpn.sh"
}

variable "vpn_instance_ami" {
  type = map(any)

  default = {
    ec2    = "ami-0022f774911c1d690"
    ubuntu = "ami-09d56f8956ab235b3"
  }
}

variable "variables" {
  default = "variables.sh"
}

variable "packages" {
  default = "packages.sh"
}

variable "certificates" {
  default = "certificates.sh"
}

variable "fw_rules" {
  description = "Firewall rules"
  #                  Protocol [-1 for all traffic]
  #                  |       From port [0 for all ports]
  #                  |       |       To port [0 for all ports]
  #                  |       |       |       Description
  #                  |       |       |       |       Link to ip_list entry
  #                  |       |       |       |       |
  type = list(tuple([string, number, number, string, number]))
  default = [
    [-1, 0, 0, "Allow all traffic", 0],
  ]
}

variable "ip_list" {
  description = "Allowed IPs"
  type        = list(list(string))
  default = [
    ["128.65.243.205/32", "83.240.158.54/32", "10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"],
  ]
}

resource "random_id" "sg" {
  byte_length = 8
}