data "aws_secretsmanager_secret" "db_master_creds" {
  name = "db-master-creds-${var.target_env}"
}


data "aws_rds_cluster" "rds_cluster" {
  cluster_identifier = "qsawsc-aurora-cluster-${var.target_env}-${var.app_env}"
}

data "aws_secretsmanager_secret_version" "db_master_creds_version" {
  secret_id = data.aws_secretsmanager_secret.db_master_creds.id
}

locals {
  db_master_creds = jsondecode(data.aws_secretsmanager_secret_version.db_master_creds_version.secret_string)
}

output "db_master_creds_string" {
  value = local.db_master_creds
  sensitive = true
}
output "database_endpoint" {
  value = data.aws_rds_cluster.rds_cluster.endpoint
}

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "ecs-cluster-${var.target_env}_${var.app_env}"
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

resource "aws_ecs_task_definition" "flyway_task" {
  family                   = "flyway-task-${var.target_env}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.flyway_cpu
  memory                   = var.flyway_memory

  container_definitions = jsonencode([
    {
      name      = "flyway-${var.target_env}-${var.app_env}"
      image     = "${var.flyway_image}"
      essential = true
      environment = [
        {
          name  = "FLYWAY_URL"
          value = "jdbc:postgresql://${data.aws_rds_cluster.rds_cluster.endpoint}/${var.db_name}"
        },
        {
          name  = "FLYWAY_USER"
          value = local.db_master_creds.username
        },
        {
          name  = "FLYWAY_PASSWORD"
          value = local.db_master_creds.password
        },
        {
          name  = "FLYWAY_DEFAULT_SCHEMA"
          value = "${var.db_schema}"
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
          awslogs-group         = "/ecs/${var.app_name}"
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
      mountPoints = []
      volumesFrom = []
      
    }
  ])
}

resource "aws_ecs_task_definition" "node_api_task" {
  family                   = "node-api-task-${var.target_env}-${var.app_env}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.api_cpu
  memory                   = var.api_memory

  container_definitions = jsonencode([
    {
      name      = "node-api-task-${var.target_env}-${var.app_env}"
      image     = "${var.api_image}"
      essential = true
      environment = [
        {
          name  = "POSTGRES_HOST"
          value = data.aws_rds_cluster.rds_cluster.endpoint
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
          name  = "DB_SCHEMA"
          value = "${var.db_schema}"
        }
      ]
    }
  ])
}


resource "aws_ecs_service" "node_api_service" {
  name            = "node-api-service-${var.target_env}-${var.app_env}"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.node_api_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

 capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight            = 100
  }


  network_configuration {
    security_groups  = [module.network.aws_security_groups.app.id]
    subnets          = module.network.aws_subnet_ids.app.ids
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.app.id
    container_name   = "node-api-task-${var.target_env}-${var.app_env}"
    container_port   = var.app_port
  }

  depends_on = [aws_iam_role_policy_attachment.ecs_task_execution_role]

  tags = local.common_tags
}