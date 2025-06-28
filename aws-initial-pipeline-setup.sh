#!/bin/bash

# Script to create AWS IAM policy, role, S3 bucket for Terraform state, and ECR repository
# for GitHub Actions CI/CD workflows. This automates the complete infrastructure
# setup needed for secure AWS deployments via GitHub Actions.
# 
# It creates:
# - IAM policy with necessary AWS permissions
# - IAM role with GitHub OIDC trust relationship
# - S3 bucket for Terraform remote state with versioning and encryption
# - ECR repository with lifecycle policies

set -e  # Exit on any error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to validate input
validate_input() {
    local input="$1"
    local field="$2"
    
    if [[ -z "$input" ]]; then
        print_error "$field cannot be empty"
        exit 1
    fi
}

# Function to validate AWS account number
validate_account_number() {
    local account="$1"
    if [[ ! "$account" =~ ^[0-9]{12}$ ]]; then
        print_error "AWS account number must be exactly 12 digits"
        exit 1
    fi
}

# Function to validate GitHub repo format
validate_repo_format() {
    local repo="$1"
    if [[ ! "$repo" =~ ^[a-zA-Z0-9_.-]+/[a-zA-Z0-9_.-]+$ ]]; then
        print_error "Repository name must be in format 'owner/repo-name'"
        exit 1
    fi
}

# Function to check if AWS CLI is installed and configured
check_aws_cli() {
    if ! command -v aws &> /dev/null; then
        print_error "AWS CLI is not installed. Please install it first."
        exit 1
    fi
    
    if ! aws sts get-caller-identity --no-cli-pager &> /dev/null; then
        print_error "AWS CLI is not configured or you don't have permissions. Please run 'aws configure' first."
        exit 1
    fi
    
    print_success "AWS CLI is properly configured"
}

# Function to create IAM policy
create_iam_policy() {
    local policy_name="$1"
    
    print_status "Creating IAM policy: $policy_name"
    
    # Create policy document
    cat > /tmp/terraform-deploy-policy.json << 'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "IAM",
      "Effect": "Allow",
      "Action": ["iam:*"],
      "Resource": ["*"]
    },
    {
      "Sid": "S3",
      "Effect": "Allow",
      "Action": ["s3:*"],
      "Resource": ["*"]
    },
    {
      "Sid": "Cloudfront",
      "Effect": "Allow",
      "Action": ["cloudfront:*"],
      "Resource": ["*"]
    },
    {
      "Sid": "ecs",
      "Effect": "Allow",
      "Action": ["ecs:*"],
      "Resource": "*"
    },
    {
      "Sid": "ecr",
      "Effect": "Allow",
      "Action": ["ecr:*"],
      "Resource": "*"
    },
    {
      "Sid": "Dynamodb",
      "Effect": "Allow",
      "Action": ["dynamodb:*"],
      "Resource": ["*"]
    },
    {
      "Sid": "APIgateway",
      "Effect": "Allow",
      "Action": ["apigateway:*"],
      "Resource": ["*"]
    },
    {
      "Sid": "RDS",
      "Effect": "Allow",
      "Action": ["rds:*"],
      "Resource": "*"
    },
    {
      "Sid": "Cloudwatch",
      "Effect": "Allow",
      "Action": ["cloudwatch:*"],
      "Resource": "*"
    },
    {
      "Sid": "EC2",
      "Effect": "Allow",
      "Action": ["ec2:*"],
      "Resource": "*"
    },
    {
      "Sid": "Autoscaling",
      "Effect": "Allow",
      "Action": ["autoscaling:*"],
      "Resource": "*"
    },
    {
      "Sid": "KMS",
      "Effect": "Allow",
      "Action": ["kms:*"],
      "Resource": "*"
    },
    {
      "Sid": "SecretsManager",
      "Effect": "Allow",
      "Action": ["secretsmanager:*"],
      "Resource": "*"
    },
    {
      "Sid": "CloudWatchLogs",
      "Effect": "Allow",
      "Action": ["logs:*"],
      "Resource": "*"
    },
    {
      "Sid": "WAF",
      "Effect": "Allow",
      "Action": ["wafv2:*"],
      "Resource": "*"
    },
    {
      "Sid": "ELB",
      "Effect": "Allow",
      "Action": ["elasticloadbalancing:*"],
      "Resource": "*"
    },
    {
      "Sid": "AppAutoScaling",
      "Effect": "Allow",
      "Action": ["application-autoscaling:*"],
      "Resource": "*"
    }
  ]
}
EOF

    # Check if policy already exists
    if aws iam get-policy --policy-arn "arn:aws:iam::${AWS_ACCOUNT_NUMBER}:policy/${policy_name}" --no-cli-pager &> /dev/null; then
        print_warning "Policy $policy_name already exists."
        print_status "Deleting existing policy..."
        aws iam delete-policy --policy-arn "arn:aws:iam::${AWS_ACCOUNT_NUMBER}:policy/${policy_name}" --no-cli-pager
        print_status "Recreating policy..."
        
        # Create new policy after deletion
        POLICY_ARN=$(aws iam create-policy \
            --policy-name "$policy_name" \
            --policy-document file:///tmp/terraform-deploy-policy.json \
            --description "Policy for GitHub Actions to deploy infrastructure via Terraform" \
            --query 'Policy.Arn' \
            --output text --no-cli-pager)
        
        print_success "Policy recreated: $POLICY_ARN"
    else
        # Create new policy
        POLICY_ARN=$(aws iam create-policy \
            --policy-name "$policy_name" \
            --policy-document file:///tmp/terraform-deploy-policy.json \
            --description "Policy for GitHub Actions to deploy infrastructure via Terraform" \
            --query 'Policy.Arn' \
            --output text --no-cli-pager)
        
        print_success "Policy created: $POLICY_ARN"
    fi
    
    # Clean up temporary file
    rm -f /tmp/terraform-deploy-policy.json
}

# Function to create IAM role
create_iam_role() {
    local role_name="$1"
    local repo_name="$2"
    local account_number="$3"
    local policy_name="$4"
    
    print_status "Creating IAM role: $role_name"
    
    # Create trust policy document
    cat > /tmp/trust-policy.json << EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "arn:aws:iam::${account_number}:oidc-provider/token.actions.githubusercontent.com"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringLike": {
                    "token.actions.githubusercontent.com:sub": "repo:${repo_name}:*"
                },
                "ForAllValues:StringEquals": {
                    "token.actions.githubusercontent.com:aud": "sts.amazonaws.com",
                    "token.actions.githubusercontent.com:iss": "https://token.actions.githubusercontent.com"
                }
            }
        }
    ]
}
EOF

    local role_arn
    # Check if role already exists
    if aws iam get-role --role-name "$role_name" --no-cli-pager &> /dev/null; then
        print_warning "Role $role_name already exists."
        role_arn="arn:aws:iam::${AWS_ACCOUNT_NUMBER}:role/${role_name}"
    else
        # Create new role
        role_arn=$(aws iam create-role \
            --role-name "$role_name" \
            --assume-role-policy-document file:///tmp/trust-policy.json \
            --description "Role for GitHub Actions to deploy infrastructure via Terraform" \
            --query 'Role.Arn' \
            --output text --no-cli-pager)
        
        print_success "Role created: $role_arn"
        
        # Wait for role to propagate through AWS systems
        print_status "Waiting for IAM role to propagate..."
        max_attempts=10
        attempt=1
        while [ $attempt -le $max_attempts ]; do
            if aws iam get-role --role-name "$role_name" --no-cli-pager &> /dev/null; then
                print_success "Role $role_name is now available"
                break
            else
                print_status "Attempt $attempt of $max_attempts: Role not yet available, waiting..."
                sleep 3
                ((attempt++))
            fi
        done
        
        if [ $attempt -gt $max_attempts ]; then
            print_warning "Role may not be fully propagated yet, but proceeding anyway"
        fi
    fi
    
    # Attach policy to role
    print_status "Attaching policy to role..."
    aws iam attach-role-policy \
        --role-name "$role_name" \
        --policy-arn "arn:aws:iam::${account_number}:policy/${policy_name}" \
        --no-cli-pager
    
    print_success "Policy attached to role"
    
    # Clean up temporary file
    rm -f /tmp/trust-policy.json
    
    # Write role ARN to a temporary file instead of echoing it
    echo "$role_arn" > /tmp/role_arn.txt
}


# Function to create S3 bucket for Terraform state
create_terraform_state_bucket() {
    local bucket_name="$1"
    local region="$2"
    
    print_status "Creating S3 bucket for Terraform state: $bucket_name"
    
    # Check if bucket already exists
    if aws s3api head-bucket --bucket "$bucket_name" --region "$region" --no-cli-pager &> /dev/null; then
        print_warning "S3 bucket $bucket_name already exists. Skipping creation."
        return
    fi
    
    # Create bucket
    if [ "$region" = "us-east-1" ]; then
        # us-east-1 doesn't need LocationConstraint
        aws s3api create-bucket \
            --bucket "$bucket_name" \
            --region "$region" \
            --no-cli-pager
    else
        aws s3api create-bucket \
            --bucket "$bucket_name" \
            --region "$region" \
            --create-bucket-configuration LocationConstraint="$region" \
            --no-cli-pager
    fi
    # Enable versioning
    aws s3api put-bucket-versioning \
        --bucket "$bucket_name" \
        --versioning-configuration Status=Enabled \
        --no-cli-pager
    
    # Enable server-side encryption
    aws s3api put-bucket-encryption \
        --bucket "$bucket_name" \
        --server-side-encryption-configuration '{
            "Rules": [
                {
                    "ApplyServerSideEncryptionByDefault": {
                        "SSEAlgorithm": "AES256"
                    },
                    "BucketKeyEnabled": true
                }
            ]
        }' \
        --no-cli-pager
    
    # Block public access
    aws s3api put-public-access-block \
        --bucket "$bucket_name" \
        --public-access-block-configuration "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true" \
        --no-cli-pager
    
    # Add bucket policy to restrict access
    cat > /tmp/bucket-policy.json << EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "DenyInsecureConnections",
            "Effect": "Deny",
            "Principal": "*",
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::${bucket_name}",
                "arn:aws:s3:::${bucket_name}/*"
            ],
            "Condition": {
                "Bool": {
                    "aws:SecureTransport": "false"
                }
            }
        }
    ]
}
EOF
    
aws s3api put-bucket-policy \
    --bucket "$bucket_name" \
    --policy file:///tmp/bucket-policy.json \
    --no-cli-pager

rm -f /tmp/bucket-policy.json

print_success "S3 bucket $bucket_name created and configured successfully"
}

# Function to create ECR repository with lifecycle policies
create_ecr_repository() {
    local repo_name="$1"
    local region="$2"
    
    print_status "Creating ECR repository: $repo_name"
    
    # Check if repository already exists
    if aws ecr describe-repositories --repository-names "$repo_name" --region "$region" --no-cli-pager &> /dev/null; then
        print_warning "ECR repository $repo_name already exists. Skipping creation."
        
        # Update repository to be mutable (in case it was previously immutable)
        aws ecr put-image-tag-mutability \
            --repository-name "$repo_name" \
            --image-tag-mutability MUTABLE \
            --region "$region" \
            --no-cli-pager
        
        print_success "ECR repository $repo_name is now mutable"
    else
        # Create new ECR repository
        aws ecr create-repository \
            --repository-name "$repo_name" \
            --image-tag-mutability MUTABLE \
            --region "$region" \
            --no-cli-pager > /dev/null
        
        print_success "ECR repository created: $repo_name"
    fi
    
    # Create lifecycle policy to manage image retention
    print_status "Setting up lifecycle policy for ECR repository..."
    
    cat > /tmp/ecr-lifecycle-policy.json << 'EOF'
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Keep only 5 most recent tagged images",
            "selection": {
                "tagStatus": "tagged",
                "tagPatternList": ["*"],
                "countType": "imageCountMoreThan",
                "countNumber": 5
            },
            "action": {
                "type": "expire"
            }
        },
        {
            "rulePriority": 2,
            "description": "Delete untagged images older than 1 day",
            "selection": {
                "tagStatus": "untagged",
                "countType": "sinceImagePushed",
                "countUnit": "days",
                "countNumber": 1
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF

    # Apply lifecycle policy
    aws ecr put-lifecycle-policy \
        --repository-name "$repo_name" \
        --lifecycle-policy-text file:///tmp/ecr-lifecycle-policy.json \
        --region "$region" \
        --no-cli-pager > /dev/null
    
    # Clean up temporary file
    rm -f /tmp/ecr-lifecycle-policy.json
    
    print_success "Lifecycle policy applied to ECR repository $repo_name"
    print_status "Policy details:"
    echo "  - Maximum tagged images: 5"
    echo "  - Untagged images older than 1 day will be deleted"
    echo "  - Repository is mutable (tags can be overwritten)"
}

# Function to check if GitHub CLI is installed and authenticated
check_github_cli() {
    if ! command -v gh &> /dev/null; then
        print_warning "GitHub CLI (gh) is not installed."
        print_status "You can install it from: https://cli.github.com/"
        return 1
    fi
    
    if ! gh auth status &> /dev/null; then
        print_warning "GitHub CLI is not authenticated."
        print_status "Please run 'gh auth login' first."
        return 1
    fi
    
    print_success "GitHub CLI is installed and authenticated"
    return 0
}

# Function to create GitHub environment and add secrets
create_github_environment_and_secrets() {
    local repo_name="$1"
    local target_env="$2"
    local role_arn="$3"
    local aws_license_plate="$4"
    local aws_region="$5"
    local ecr_repo_name="$6"
    local aws_account_number="$7"
    
    print_status "Creating GitHub environment: $target_env"
    
    # Check if environment already exists
    if gh api "repos/$repo_name/environments/$target_env" &> /dev/null; then
        print_warning "Environment $target_env already exists. Will update secrets."
    else
        # Create environment
        gh api "repos/$repo_name/environments/$target_env" \
            --method PUT \
            --field wait_timer=0 \
            --field reviewers='[]' \
            --field deployment_branch_policy='{"protected_branches":false,"custom_branch_policies":false}' \
            > /dev/null
        
        print_success "Environment $target_env created successfully"
    fi
    
    print_status "Adding secrets to environment: $target_env"
    
    # Add environment-specific secrets
    gh secret set AWS_DEPLOY_ROLE_ARN \
        --repo "$repo_name" \
        --env "$target_env" \
        --body "$role_arn"
    
    gh secret set AWS_LICENSE_PLATE \
        --repo "$repo_name" \
        --env "$target_env" \
        --body "$aws_license_plate"
    
    
    gh secret set AWS_ACCOUNT_NUMBER \
        --repo "$repo_name" \
        --env "$target_env" \
        --body "$aws_account_number"
    
    
    print_success "Secrets added to environment $target_env:"
    echo "  - AWS_DEPLOY_ROLE_ARN"
    echo "  - AWS_LICENSE_PLATE"
    echo "  - AWS_ACCOUNT_NUMBER"
}

# Function to validate GitHub repository access
validate_github_repo_access() {
    local repo_name="$1"
    
    print_status "Validating access to GitHub repository: $repo_name"
    
    if ! gh repo view "$repo_name" &> /dev/null; then
        print_error "Cannot access repository $repo_name"
        print_error "Please check:"
        print_error "  1. Repository name is correct (format: owner/repo-name)"
        print_error "  2. You have access to the repository"
        print_error "  3. Your GitHub token has the required permissions"
        return 1
    fi
    
    print_success "Repository access validated"
    return 0
}

# Function to check required GitHub permissions
check_github_permissions() {
    local repo_name="$1"
    
    print_status "Checking GitHub permissions for repository operations..."
    
    # Try to list environments to check permissions
    if ! gh api "repos/$repo_name/environments" &> /dev/null; then
        print_warning "May not have sufficient permissions to manage environments and secrets"
        print_status "Required GitHub token scopes:"
        echo "  - repo (full repository access)"
        echo "  - admin:repo_hook (if using webhooks)"
        echo "  - admin:org (if repository is in an organization)"
        
        read -p "Do you want to continue anyway? (y/N): " CONTINUE_ANYWAY
        if [[ ! "$CONTINUE_ANYWAY" =~ ^[Yy]$ ]]; then
            return 1
        fi
    fi
    
    return 0
}

# Main script
main() {
    print_status "AWS IAM Policy and Role Setup for GitHub Actions"
    print_status "=============================================="
    echo
    
    # Check AWS CLI
    check_aws_cli
    echo
    
    # Get current AWS account number
    CURRENT_ACCOUNT=$(aws sts get-caller-identity --query Account --output text --no-cli-pager)
    print_status "Current AWS Account: $CURRENT_ACCOUNT"
    echo
    
    # Collect user input
    read -p "Enter GitHub repository name (format: owner/repo-name): " REPO_NAME
    validate_input "$REPO_NAME" "Repository name"
    validate_repo_format "$REPO_NAME"
    
    read -p "Enter AWS account number [$CURRENT_ACCOUNT]: " AWS_ACCOUNT_NUMBER
    AWS_ACCOUNT_NUMBER=${AWS_ACCOUNT_NUMBER:-$CURRENT_ACCOUNT}
    validate_account_number "$AWS_ACCOUNT_NUMBER"
    
    read -p "Enter AWS license plate (6 characters): " AWS_LICENSE_PLATE
    validate_input "$AWS_LICENSE_PLATE" "AWS license plate"
    if [[ ! "$AWS_LICENSE_PLATE" =~ ^[a-zA-Z0-9]{6}$ ]]; then
        print_error "AWS license plate must be exactly 6 alphanumeric characters"
        exit 1
    fi
    
    read -p "Enter target environment (e.g., dev, test, prod): " TARGET_ENV
    validate_input "$TARGET_ENV" "Target environment"
    
    # Get current AWS region
    CURRENT_REGION=$(aws configure get region --no-cli-pager)
    read -p "Enter AWS region [$CURRENT_REGION]: " AWS_REGION
    AWS_REGION=${AWS_REGION:-$CURRENT_REGION}
    validate_input "$AWS_REGION" "AWS region"
    
    read -p "Enter IAM policy name [TerraformDeployPolicy]: " POLICY_NAME
    POLICY_NAME=${POLICY_NAME:-TerraformDeployPolicy}
    validate_input "$POLICY_NAME" "Policy name"
    
    read -p "Enter IAM role name [GHA_CI_CD]: " ROLE_NAME
    ROLE_NAME=${ROLE_NAME:-GHA_CI_CD}
    validate_input "$ROLE_NAME" "Role name"
    
    # Extract repo name from GitHub repository for ECR
    read -p "Enter ECR repository name [$REPO_NAME]: " ECR_REPO_NAME
    ECR_REPO_NAME=${ECR_REPO_NAME:-$REPO_NAME}
    validate_input "$REPO_NAME" "ECR repository name"
    
    # Generate resource names based on inputs
    TERRAFORM_STATE_BUCKET="terraform-remote-state-${AWS_LICENSE_PLATE}-${TARGET_ENV}"
    
    echo
    print_status "Configuration Summary:"
    echo "  Repository: $REPO_NAME"
    echo "  AWS Account: $AWS_ACCOUNT_NUMBER"
    echo "  AWS License Plate: $AWS_LICENSE_PLATE"
    echo "  Target Environment: $TARGET_ENV"
    echo "  AWS Region: $AWS_REGION"
    echo "  Policy Name: $POLICY_NAME"
    echo "  Role Name: $ROLE_NAME"
    echo "  ECR Repository: $ECR_REPO_NAME"
    echo "  Terraform State Bucket: $TERRAFORM_STATE_BUCKET"
    echo
    
    read -p "Do you want to proceed? (y/N): " CONFIRM
    if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
        print_status "Operation cancelled"
        exit 0
    fi
    
    echo
    print_status "Starting deployment setup..."
    
    # Create Terraform remote state infrastructure
    print_status "Creating Terraform remote state infrastructure..."
    create_terraform_state_bucket "$TERRAFORM_STATE_BUCKET" "$AWS_REGION"
    echo
    
    # Create IAM policy
    create_iam_policy "$POLICY_NAME"
    echo
    
    # Create IAM role
    create_iam_role "$ROLE_NAME" "$REPO_NAME" "$AWS_ACCOUNT_NUMBER" "$POLICY_NAME"
    
    # Read the role ARN from the temporary file
    ROLE_ARN=$(cat /tmp/role_arn.txt)
    rm -f /tmp/role_arn.txt
    echo
    
    # Create ECR repository
    create_ecr_repository "$ECR_REPO_NAME" "$AWS_REGION"
    echo
    
    # Ask about GitHub secrets automation
    echo
    print_status "GitHub Environment and Secrets Setup"
    print_status "===================================="
    echo
    read -p "Would you like to automatically create GitHub environment and add secrets? (y/N): " CREATE_GH_SECRETS
    
    if [[ "$CREATE_GH_SECRETS" =~ ^[Yy]$ ]]; then
        if check_github_cli; then
            if validate_github_repo_access "$REPO_NAME"; then
                if check_github_permissions "$REPO_NAME"; then
                    echo
                    print_status "Creating GitHub environment and adding secrets..."
                    create_github_environment_and_secrets "$REPO_NAME" "$TARGET_ENV" "$ROLE_ARN" "$AWS_LICENSE_PLATE" "$AWS_REGION" "$ECR_REPO_NAME" "$AWS_ACCOUNT_NUMBER"
                    echo
                    print_success "GitHub environment and secrets configured successfully!"
                else
                    print_error "Insufficient GitHub permissions. Skipping GitHub setup."
                fi
            else
                print_error "Cannot access GitHub repository. Skipping GitHub setup."
            fi
        else
            print_warning "GitHub CLI not available. Skipping GitHub setup."
        fi
    else
        print_status "Skipping GitHub environment and secrets setup."
    fi
    
    echo
    print_success "Setup completed successfully!"
    echo
    print_status "Created Resources:"
    echo "  - S3 Bucket: $TERRAFORM_STATE_BUCKET"
    echo "  - IAM Policy: $POLICY_NAME"
    echo "  - IAM Role: $ROLE_NAME"
    echo "  - ECR Repository: $ECR_REPO_NAME"
    
    # Check if GitHub setup was completed successfully
    GITHUB_SETUP_COMPLETED=false
    if [[ "$CREATE_GH_SECRETS" =~ ^[Yy]$ ]] && check_github_cli &> /dev/null && validate_github_repo_access "$REPO_NAME" &> /dev/null && check_github_permissions "$REPO_NAME" &> /dev/null; then
        echo "  - GitHub Environment: $TARGET_ENV"
        echo "  - GitHub Secrets: Configured"
        GITHUB_SETUP_COMPLETED=true
    fi
    echo
    
    if [[ "$GITHUB_SETUP_COMPLETED" == "false" ]]; then
        print_status "Manual GitHub Setup Required:"
        echo "1. Create GitHub environment '$TARGET_ENV' in your repository"
        echo "2. Add the following secrets to your GitHub repository environment '$TARGET_ENV':"
        echo "   - AWS_DEPLOY_ROLE_ARN: $ROLE_ARN"
        echo "   - AWS_LICENSE_PLATE: $AWS_LICENSE_PLATE"
        echo "   - AWS_REGION: $AWS_REGION"
        echo "   - ECR_REPOSITORY: $ECR_REPO_NAME"
        echo "   - AWS_ACCOUNT_NUMBER: $AWS_ACCOUNT_NUMBER"
        echo "   - TARGET_ENV: $TARGET_ENV"
        echo
        echo "3. You can add these secrets via:"
        echo "   - Repository Settings > Environments > $TARGET_ENV > Environment secrets"
        echo "   - Or use GitHub CLI commands:"
        echo "     gh secret set AWS_DEPLOY_ROLE_ARN --env $TARGET_ENV --body \"$ROLE_ARN\""
        echo "     gh secret set AWS_LICENSE_PLATE --env $TARGET_ENV --body \"$AWS_LICENSE_PLATE\""
        echo "     gh secret set AWS_ACCOUNT_NUMBER --env $TARGET_ENV --body \"$AWS_ACCOUNT_NUMBER\""
        echo
    else
        print_status "GitHub Configuration Complete!"
        echo "✓ Environment '$TARGET_ENV' created"
        echo "✓ All required secrets added to the environment"
        echo
    fi
    
    print_status "Terragrunt Environment Variables:"
    echo "   - stack_prefix: <your-application-prefix>"
    echo "   - target_env: $TARGET_ENV"
    echo "   - aws_license_plate: $AWS_LICENSE_PLATE"
    echo "   - app_env: <your-app-environment>"
    echo "   - api_image: <your-api-docker-image>"
    echo "   - repo_name: $REPO_NAME"
    echo "   - ecr_repository: $ECR_REPO_NAME"
    echo
    print_status "ECR Repository Details:"
    echo "   - Registry: ${AWS_ACCOUNT_NUMBER}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}"
    echo "   - Repository is mutable with lifecycle policies applied"
    echo
    print_status "Your Terraform remote state backend is now ready!"
    print_status "Your GitHub Actions workflows should now be able to deploy to AWS!"
}

# Run main function
main "$@"