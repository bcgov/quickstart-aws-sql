# ECR repositories for production images
resource "aws_ecr_repository" "backend" {
  count                = var.app_env == "prod" ? 1 : 0
  name                 = "quickstart-aws-containers-backend-prod"
  image_tag_mutability = var.image_tag_mutability

  image_scanning_configuration {
    scan_on_push = var.image_scanning_enabled
  }

  lifecycle {
    prevent_destroy = true
  }

  tags = merge(var.common_tags, var.tags, {
    Name = "${var.app_name}-backend-ecr"
  })
}

resource "aws_ecr_repository" "migrations" {
  count                = var.app_env == "prod" ? 1 : 0
  name                 = "quickstart-aws-containers-migrations-prod"
  image_tag_mutability = var.image_tag_mutability

  image_scanning_configuration {
    scan_on_push = var.image_scanning_enabled
  }

  lifecycle {
    prevent_destroy = true
  }

  tags = merge(var.common_tags, var.tags, {
    Name = "${var.app_name}-migrations-ecr"
  })
}

# ECR lifecycle policies to manage image retention
resource "aws_ecr_lifecycle_policy" "backend" {
  count      = var.app_env == "prod" ? 1 : 0
  repository = aws_ecr_repository.backend[0].name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 production images"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["prod", "v"]
          countType     = "imageCountMoreThan"
          countNumber   = 10
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Delete untagged images older than 1 day"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 1
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

resource "aws_ecr_lifecycle_policy" "migrations" {
  count      = var.app_env == "prod" ? 1 : 0
  repository = aws_ecr_repository.migrations[0].name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 production images"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["prod", "v"]
          countType     = "imageCountMoreThan"
          countNumber   = 10
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Delete untagged images older than 1 day"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 1
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

# Output ECR repository URLs for use in other resources
output "backend_ecr_repository_url" {
  description = "URL of the backend ECR repository"
  value       = var.app_env == "prod" ? aws_ecr_repository.backend[0].repository_url : null
}

output "migrations_ecr_repository_url" {
  description = "URL of the migrations ECR repository"
  value       = var.app_env == "prod" ? aws_ecr_repository.migrations[0].repository_url : null
}
