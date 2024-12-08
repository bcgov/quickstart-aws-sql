data "aws_vpc" "selected" {
  state = "available"
}

data "aws_subnet" "a_data" {
  filter {
    name   = "tag:Name"
    values = [var.subnet_data_a]
  }
}

data "aws_subnet" "b_data" {
  filter {
    name   = "tag:Name"
    values = [var.subnet_data_b]
  }
}

