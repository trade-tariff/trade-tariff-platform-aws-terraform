resource "aws_security_group" "ssh" {
  name        = "allow-ssh"
  description = "Allow inbound SSH traffic"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.ssh.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_outbound" {
  security_group_id = aws_security_group.ssh.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
