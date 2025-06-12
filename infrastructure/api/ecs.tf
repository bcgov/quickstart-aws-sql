locals {
  container_name = "${var.app_name}"
  
}
data "aws_secretsmanager_secret" "db_master_creds" {
  name = "${var.db_cluster_name}"
}

data "aws_rds_cluster" "rds_cluster" {
  cluster_identifier = "${var.db_cluster_name}" 
}

data "aws_secretsmanager_secret_version" "db_master_creds_version" {
  secret_id = data.aws_secretsmanager_secret.db_master_creds.id
}

locals {
  db_master_creds = jsondecode(data.aws_secretsmanager_secret_version.db_master_creds_version.secret_string)
}


resource "aws_ecs_cluster" "ecs_cluster" {
  name = "ecs-cluster-${var.app_name}"
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
  input = "${timestamp()}"
}

resource "aws_ecs_task_definition" "flyway_task" {
  family                   = "${var.app_name}-flyway-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.app_container_role.arn
  container_definitions = jsonencode([
    {
      name      = "${var.app_name}-flyway"
      image     = "${var.flyway_image}"
      essential   = true
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
        },
        {
          name  = "FLYWAY_CONNECT_RETRIES"
          value = "2"
        },
        {
          name  = "FLYWAY_GROUP"
          value = "true"
        }
      ]
      
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-create-group  = "true"
          awslogs-group         = "/ecs/${var.app_name}/flyway"
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
      mountPoints = []
      volumesFrom = []
      
    }
  ])
  lifecycle {
    replace_triggered_by = [terraform_data.trigger_flyway]
  }
  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command = <<-EOF
    set -euo pipefail

    max_attempts=5
    attempt=1
    task_arn=""
    while [[ $attempt -le $max_attempts ]]; do
      echo "Starting Flyway task (attempt $attempt)..."
      task_arn=$(aws ecs run-task \
        --task-definition ${var.app_name}-flyway-task \
        --cluster ${aws_ecs_cluster.ecs_cluster.id} \
        --count 1 \
        --network-configuration awsvpcConfiguration={securityGroups=[${data.aws_security_group.app.id}],subnets=${data.aws_subnets.app.ids[0]},assignPublicIp=DISABLED} \
        --query 'tasks[0].taskArn' \
        --output text)

      if [[ -n "$task_arn" && "$task_arn" != "None" ]]; then
        echo "Flyway task started with ARN: $task_arn at $(date)."
        break
      fi
      echo "No task ARN returned. Retrying in 5 seconds..."
      sleep 5
      ((attempt++))
    done
    if [[ -z "$task_arn" || "$task_arn" == "None" ]]; then
      echo "ERROR: Failed to start ECS task after $max_attempts attempts."
      exit 1
    fi
    echo "Waiting for Flyway task to complete..."
    aws ecs wait tasks-stopped --cluster ${aws_ecs_cluster.ecs_cluster.id} --tasks $task_arn
    
    echo "Flyway task completed, at $(date)."
    
    task_status=$(aws ecs describe-tasks --cluster ${aws_ecs_cluster.ecs_cluster.id} --tasks $task_arn --query 'tasks[0].lastStatus' --output text)
    echo "Flyway task status: $task_status at $(date)."
    log_stream_name=$(aws logs describe-log-streams \
      --log-group-name "/ecs/${var.app_name}/flyway" \
      --order-by "LastEventTime" \
      --descending \
      --limit 1 \
      --query 'logStreams[0].logStreamName' \
      --output text)

    echo "Fetching logs from log stream: $log_stream_name"

    aws logs get-log-events \
      --log-group-name "/ecs/${var.app_name}/flyway" \
      --log-stream-name $log_stream_name \
      --limit 1000 \
      --no-cli-pager
    task_exit_code=$(aws ecs describe-tasks \
        --cluster ${aws_ecs_cluster.ecs_cluster.id} \
        --tasks $task_arn \
        --query 'tasks[0].containers[0].exitCode' \
        --output text)

    if [ "$task_exit_code" != "0" ]; then
      echo "Flyway task failed with exit code: $task_exit_code"
      exit 1
    fi
  EOF
  }
}

resource "aws_ecs_task_definition" "node_api_task" {
  family                   = "${var.app_name}-task"
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
          value = data.aws_rds_cluster.rds_cluster.endpoint
        },
        {
          name  = "POSTGRES_READ_ONLY_HOST"
          value = data.aws_rds_cluster.rds_cluster.reader_endpoint
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
        }
        ,
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
}


resource "aws_ecs_service" "node_api_service" {
  name            = "${var.app_name}-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.node_api_task.arn
  desired_count   = 1
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
    security_groups  = [data.aws_security_group.app.id]
    subnets          = data.aws_subnets.app.ids
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.app.id
    container_name   = "${local.container_name}"
    container_port   = var.app_port
  }
  wait_for_steady_state = true
  depends_on = [aws_iam_role_policy_attachment.ecs_task_execution_role]
  tags = local.common_tags
}