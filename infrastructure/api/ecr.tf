terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
resource "aws_ecr_repository" "this" {
  for_each             = toset(var.repository_names)
  name                 = "${each.key}-${var.app_env}"
  image_tag_mutability = var.image_tag_mutability

  image_scanning_configuration {
    scan_on_push = var.image_scanning_enabled
  }

  tags = var.tags
}
resource "aws_ecr_pull_through_cache_rule" "github_cache_rule" {
  ecr_repository_prefix = "github"
  upstream_registry_url = "ghcr.io"
}


data "aws_iam_policy_document" "ecr_read" {

  statement {
    sid    = "ECRRead"
    effect = "Allow"

    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:DescribeImages",
      "ecr:DescribeRepositories",
      "ecr:GetAuthorizationToken",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetRepositoryPolicy",
      "ecr:ListImages",
    ]

    principals {
      identifiers = var.read_principals
      type        = "AWS"
    }
  }
}

data "aws_iam_policy_document" "ecr_read_write" {

  source_policy_documents = [data.aws_iam_policy_document.ecr_read.json]

  statement {
    sid    = "ECRWrite"
    effect = "Allow"

    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:CompleteLayerUpload",
      "ecr:DescribeImages",
      "ecr:DescribeRepositories",
      "ecr:GetAuthorizationToken",
      "ecr:GetDownloadUrlForLayer",
      "ecr:InitiateLayerUpload",
      "ecr:ListImages",
      "ecr:PutImage",
      "ecr:UploadLayerPart",
    ]

    principals {
      identifiers = var.write_principals
      type        = "AWS"
    }
  }
}

# Combining read and write policies is required because only one policy may be applied to a repository
resource "aws_ecr_repository_policy" "this" {

  for_each   = aws_ecr_repository.this
  repository = aws_ecr_repository.this[each.key].name
  policy     = length(var.write_principals) > 0 ? data.aws_iam_policy_document.ecr_read_write.json : data.aws_iam_policy_document.ecr_read.json
}