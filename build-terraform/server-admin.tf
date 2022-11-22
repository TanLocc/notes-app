resource "aws_instance" "admin-server-production" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.small"
  key_name = "server-keypair"
  tags = {
    Name = "master-server-production"
  }
  subnet_id = module.vpc.public_subnets[0]
  depends_on = [
    module.vpc
  ]

  root_block_device {
    delete_on_termination = true
    iops = 150
    volume_size = 30
    volume_type = "gp3"
  }
}

resource "aws_security_group" "allow_all_trafic" {
  name        = "allow_all_trafic_"
  description = "Allow all traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_all_trafic"
  }
}

resource "aws_network_interface_sg_attachment" "sg_attachment" {
  security_group_id    = "${aws_security_group.allow_all_trafic.id}"
  network_interface_id = "${aws_instance.admin-server-production.primary_network_interface_id}"
}
