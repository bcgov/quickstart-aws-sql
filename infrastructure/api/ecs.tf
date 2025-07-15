locals {
  container_name = var.app_name
}

# Try to fetch secrets manager secret, but don't fail if it doesn't exist
data "aws_secretsmanager_secret" "db_master_creds" {
  count = var.db_cluster_name != "" ? 1 : 0
  name  = var.db_cluster_name
}

# Try to fetch RDS cluster, but don't fail if it doesn't exist
data "aws_rds_cluster" "rds_cluster" {
  count              = var.db_cluster_name != "" ? 1 : 0
  cluster_identifier = var.db_cluster_name
}

# Try to fetch secret version, but don't fail if secret doesn't exist
data "aws_secretsmanager_secret_version" "db_master_creds_version" {
  count     = length(data.aws_secretsmanager_secret.db_master_creds) > 0 ? 1 : 0
  secret_id = data.aws_secretsmanager_secret.db_master_creds[0].id
}

locals {
  # Use try() to safely access data sources with fallback values
  db_master_creds = try(
    jsondecode(data.aws_secretsmanager_secret_version.db_master_creds_version[0].secret_string),
    {
      username = "postgres"
      password = "changeme"
    }
  )

  # Provide default database endpoints with try() for safe access
  db_endpoint = try(
    data.aws_rds_cluster.rds_cluster[0].endpoint,
    "localhost"
  )

  db_reader_endpoint = try(
    data.aws_rds_cluster.rds_cluster[0].reader_endpoint,
    "localhost"
  )

  # Flag to indicate if database resources are available
  db_resources_available = var.db_cluster_name != "" && length(data.aws_rds_cluster.rds_cluster) > 0
}


resource "aws_ecs_cluster" "ecs_cluster" {
  name = var.app_name
  tags = module.common.common_tags
}

resource "aws_ecs_cluster_capacity_providers" "ecs_cluster_capacity_providers" {
  cluster_name = aws_ecs_cluster.ecs_cluster.name

  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE_SPOT"
  }
}

resource "terraform_data" "trigger_flyway" {
  count = var.db_cluster_name != "" ? 1 : 0
  input = timestamp()
}

module "flyway_task" {
  count              = var.db_cluster_name != "" ? 1 : 0
  source             = "git::https://github.com/bcgov/quickstart-aws-helpers.git//terraform/modules/flyway?ref=feat/modules-readme"
  app_name           = "${var.app_name}-flyway"
  aws_region         = var.aws_region
  db_cluster_name    = var.db_cluster_name
  db_name            = var.db_name
  db_schema          = var.db_schema
  db_password        = local.db_master_creds.password
  db_username        = local.db_master_creds.username
  db_host            = local.db_endpoint
  flyway_image       = var.flyway_image
  ecs_cluster_name   = aws_ecs_cluster.ecs_cluster.name
  ecs_cluster_id     = aws_ecs_cluster.ecs_cluster.id
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn      = aws_iam_role.app_container_role.arn
  subnet_ids         = [module.networking.subnets.app.ids[0]]
  security_group_ids = [module.networking.security_groups.app.id]
  tags               = module.common.common_tags
}

resource "aws_ecs_task_definition" "node_api_task" {
  family                   = var.app_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.api_cpu
  memory                   = var.api_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.app_container_role.arn
  container_definitions = jsonencode([
    {
      name      = "${local.container_name}"
      image     = "${var.api_image}"
      essential = true
      environment = [
        {
          name  = "POSTGRES_HOST"
          value = local.db_endpoint
        },
        {
          name  = "POSTGRES_READ_ONLY_HOST"
          value = local.db_reader_endpoint
        },
        {
          name  = "POSTGRES_USER"
          value = local.db_master_creds.username
        },
        {
          name  = "POSTGRES_PASSWORD"
          value = local.db_master_creds.password
        },
        {
          name  = "POSTGRES_DATABASE"
          value = var.db_name
        },
        {
          name  = "POSTGRES_SCHEMA"
          value = "${var.db_schema}"
        },
        {
          name  = "POSTGRES_POOL_SIZE"
          value = "${var.postgres_pool_size}"
        },
        {
          name  = "PORT"
          value = "3000"
        }
      ]
      portMappings = [
        {
          protocol      = "tcp"
          containerPort = var.app_port
          hostPort      = var.app_port
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-create-group  = "true"
          awslogs-group         = "/ecs/${var.app_name}/api"
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
      mountPoints = []
      volumesFrom = []
    }
  ])
  lifecycle {
    create_before_destroy = true
  }
  tags = module.common.common_tags
}


resource "aws_ecs_service" "node_api_service" {
  name                              = var.app_name
  cluster                           = aws_ecs_cluster.ecs_cluster.id
  task_definition                   = aws_ecs_task_definition.node_api_task.arn
  desired_count                     = 1
  health_check_grace_period_seconds = 60

  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight            = 80
  }
  capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = 20
    base              = 1
  }

  network_configuration {
    security_groups  = [module.networking.security_groups.app.id]
    subnets          = module.networking.subnets.app.ids
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.app.id
    container_name   = local.container_name
    container_port   = var.app_port
  }
  wait_for_steady_state = true
  depends_on            = [aws_iam_role_policy_attachment.ecs_task_execution_role]
  tags                  = module.common.common_tags
}