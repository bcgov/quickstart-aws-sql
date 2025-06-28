# Common Networking Module Outputs
output "vpc" {
  description = "VPC information"
  value = {
    id           = data.aws_vpc.main.id
    cidr_block   = data.aws_vpc.main.cidr_block
    name         = local.vpc_name
  }
}

output "environment" {
  description = "Processed environment name (capitalized)"
  value       = local.environment
}

output "subnets" {
  description = "Subnet information by tier"
  value = {
    web = {
      ids   = data.aws_subnets.web.ids
      names = local.web_subnet_names
    }
    app = {
      ids   = data.aws_subnets.app.ids
      names = local.app_subnet_names
    }
    data = {
      ids   = data.aws_subnets.data.ids
      names = local.data_subnet_names
    }
  }
}

output "security_groups" {
  description = "Security group information by tier"
  value = {
    web = {
      id   = data.aws_security_group.web.id
      name = data.aws_security_group.web.name
    }
    app = {
      id   = data.aws_security_group.app.id
      name = data.aws_security_group.app.name
    }
    data = {
      id   = data.aws_security_group.data.id
      name = data.aws_security_group.data.name
    }
  }
}

output "subnet_details" {
  description = "Detailed subnet information"
  value = {
    web  = data.aws_subnet.web
    app  = data.aws_subnet.app
    data = data.aws_subnet.data
  }
}
