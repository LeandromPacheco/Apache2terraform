resource "aws_instance" "instance" {
  ami = "ami-0885b1f6bd170450c"
  instance_type = "t2.micro"
  key_name = var.key_name
  security_groups = [
    var.sec_group_name,
  ]
  tags = var.tags
  volume_tags = var.volume_tags
  vpc_security_group_ids = [
    aws_security_group.instance.id,
  ]
  root_block_device {
    volume_size = var.volume_size
  }
  user_data = <<-EOF
            #! /bin/bash
            sudo hostnamectl set-hostname apache2
            sudo sh -c 'echo root:Passw0rd | chpasswd'
            sudo apt update
            sudo apt-get -y upgrade
            sudo apt-get -y install apache2
            sudo a2enmod ssl
            sudo a2ensite default-ssl.conf
            sudo systemctl restart apache2
            sudo systemctl enable apache2
            sudo sed -i 's|80|8080|g' /etc/apache2/ports.conf
            sudo sed -i 's|443|8443|g' /etc/apache2/ports.conf
            sudo systemctl restart apache2
            sudo sed -i 's|443|8443|g' /etc/apache2/sites-available/default-ssl.conf
            EOF
}

resource "aws_security_group" "instance" {
  description = var.sec_group_description
  egress = [
    {
      cidr_blocks = [
        "0.0.0.0/0",
      ]
      description = ""
      from_port = 0
      ipv6_cidr_blocks = []
      prefix_list_ids = []
      protocol = "-1"
      security_groups = []
      self = false
      to_port = 0
    },
  ]
  ingress = [
  for _port in var.port_list:
  {
    cidr_blocks = [
    for _ip in var.ip_list:
    _ip
    ]
    description = ""
    from_port = _port
    ipv6_cidr_blocks = []
    prefix_list_ids = []
    protocol = "tcp"
    security_groups = []
    self = false
    to_port = _port
  }
  ]
  name = var.sec_group_name
}
