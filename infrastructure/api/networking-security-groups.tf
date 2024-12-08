resource "aws_security_group" "custom_app_sg" {
    name = "custom_app_sg"
    description = "security group for application tier"
    vpc_id = data.aws_vpc.selected.id
    revoke_rules_on_delete = true

    tags = {
        Name = "custom_app_sg"
        managed-by = "terraform"
    }

}

resource "aws_vpc_security_group_egress_rule" "custom_app_sg_outbound" {
  security_group_id = aws_security_group.custom_app_sg.id
  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
  description = "Allow All Outbound Traffic"
}

