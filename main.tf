resource "aws_instance" "vpn" {
  ami           = var.distro_ec2 == true ? var.vpn_instance_ami["ec2"] : var.vpn_instance_ami["ubuntu"]
  instance_type = "t3.micro"
  key_name      = var.key_name

  tags = {
    "Name" = "VPN Server and Desktop"
  }

  root_block_device {
    volume_size = var.volume_size
  }
  user_data = data.template_cloudinit_config.config-vpn.rendered

  vpc_security_group_ids = [aws_security_group.instance.id]

  source_dest_check = false
}

resource "aws_eip" "vpn_eip" {
  domain = "vpc"

}

resource "aws_eip_association" "vpn_eip_assoc" {
  instance_id   = aws_instance.vpn.id
  allocation_id = aws_eip.vpn_eip.id
}

resource "aws_security_group" "instance" {
  name = "${random_id.sg.hex} VPN Server and Desktop SG"
  egress = [
    {
      cidr_blocks = [
        "0.0.0.0/0",
      ]
      description      = ""
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = []
      self             = false
      to_port          = 0
    },
  ]
  ingress = [
    for _fw_rule in var.fw_rules :
    {
      cidr_blocks = [
        for _ip in var.ip_list[_fw_rule[4]] :
        _ip
      ]
      description      = _fw_rule[3]
      from_port        = _fw_rule[1]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = _fw_rule[0]
      security_groups  = []
      self             = false
      to_port          = _fw_rule[2]
    }
  ]
}