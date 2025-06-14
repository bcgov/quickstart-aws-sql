# GitHub Actions Workflows Guide

This document provides detailed explanations of the GitHub Actions workflows used in this repository. It's designed to help developers understand the CI/CD pipeline structure, the purpose of each workflow, and how they work together to automate the development and deployment process.

## Workflow Categories

The workflows in this repository are organized into three main categories:

1. **Main Workflows**: Primary entry points triggered by GitHub events
2. **Composite Workflows**: Reusable workflow components called by main workflows
3. **Resource Management Workflows**: Specialized workflows for AWS resource management

## Main Workflows

### `pr-open.yml`

**Trigger**: 
- Pull request open or update
- Manual workflow dispatch (for deploying to dev environment)

**Purpose**: Validates the proposed changes to ensure they meet quality standards and work as expected. Additionally allows manual deployment to the dev environment through workflow dispatch.

**Concurrency**:
- Group-based concurrency controls to prevent overlapping operations
- Jobs can be canceled in progress for newer runs of the same PR

**Steps**:
1. Uses reusable `.builds.yml` workflow to build container images for backend, frontend, and migrations .
2. Plans infrastructure changes using Terraform/Terragrunt with concurrency controls
3. Runs comprehensive tests on the codebase including:
   - Backend unit tests with a PostgreSQL service container
   - Frontend unit tests
   - Security scanning with Trivy
4. SonarCloud analysis for code quality
5. For workflow dispatch events:
   - Resumes paused resources in the dev environment with concurrency control
   - Deploys the stack to the dev environment for testing with concurrency protection

**Permissions**: 
- Enhanced security permissions including attestations for vulnerability scanning
- Pull request write access for status updates

**Outputs**: Container images with appropriate tags, test results, SonarCloud reports, and (for workflow dispatch) a deployed environment

### `pr-validate.yml`

**Trigger**: Pull request targeting the main branch

**Purpose**: Ensures code quality and validates the proposed changes.

**Steps**:
1. Lints code using ESLint
2. Checks for proper formatting with Prettier
3. Validates Terraform configurations to detect potential issues
4. Enforces conventional commit message format

**Outputs**: Validation status, with failures blocking PR merges

### `pr-close.yml`

**Trigger**: Pull request closed

**Purpose**: Cleans up resources associated with the PR to avoid unnecessary costs.

**Steps**:
1. Identifies the PR number
2. Destroys any PR-specific infrastructure that was deployed
3. Removes any container images tagged with the PR number

**Outputs**: Confirmation of resource cleanup

### `merge.yml`

**Trigger**: Push to main branch (merge) or manual workflow dispatch with PR number

**Purpose**: Creates production-ready resources and deploys to both dev and test environments in sequence.

**Concurrency**: Ensures only one deployment runs at a time for the main branch

**Steps**:
1. Determines the PR number that was merged
2. Resumes all AWS resources (dev, test, and prod) before deployment
3. Deploys the stack to the dev environment using Terragrunt
4. Retags container images with 'dev' tag
5. Runs end-to-end tests against the deployed dev environment
6. Deploys the stack to the test environment using Terragrunt
7. Retags container images with 'test' tag
8. Pauses all AWS resources after successful deployment to save costs

**Outputs**: 
- Deployed applications in both dev and test environments
- Container images tagged with PR number, 'dev', and 'test' tags

### `release.yml`

**Trigger**: Manual workflow dispatch

**Purpose**: Creates a new release and deploys to the production environment.

**Steps**:
1. Generates a new version number and changelog using Conventional Commits
2. Retags container images with the release version
3. Deploys the stack to the production environment
4. Creates a GitHub release with release notes

**Outputs**: Production deployment, GitHub release, versioned container images

## Composite Workflows

### `.tests.yml`

**Purpose**: Standardized test execution for backend and frontend components.

**Details**:
- Sets up a PostgreSQL service container for backend tests
- Runs unit tests with code coverage reporting
- Analyzes code with SonarCloud
- Designed to be reusable across different workflows

### `.e2e.yml`

**Purpose**: Executes end-to-end tests against deployed environments.

**Details**:
- Can use either deployed URLs or local containers
- Sets up the necessary test environment
- Runs Playwright tests against the frontend
- Captures test results and screenshots

### `.load-test.yml`

**Purpose**: Performance testing to validate scalability.

**Details**:
- Uses k6 to execute load tests
- Tests both backend and frontend components
- Configurable with different load profiles (VUs and duration)
- Reports performance metrics

### `.deploy_stack.yml`

**Purpose**: Standardized process for deploying the complete application stack.

**Details**:
- Handles all infrastructure components (database, API, frontend)
- Uses Terragrunt to manage deployment
- Supports different environments (dev, test, prod)
- Exposes important outputs like API Gateway URL and CloudFront domain
- Orchestrates deployment in the correct order to ensure dependencies are met
- Sets up ECS tasks including the Flyway migration task and main application task
- Configures the task with environment variables for database connectivity
- Manages secrets from AWS Secrets Manager for secure database access

### `.destroy_stack.yml`

**Purpose**: Clean removal of deployed infrastructure.

**Details**:
- Safe teardown of resources in reverse dependency order
- Handles state file management
- Ensures complete cleanup to avoid orphaned resources

### `.stack-prefix.yml`

**Purpose**: Standardizes stack naming conventions.

**Details**:
- Generates consistent resource prefixes
- Reused by multiple workflows
- Ensures naming consistency across environments

### `.deployer.yml`

**Purpose**: Standardized deployment process for individual components.

**Details**:
- Modular approach to deployment
- Can be used for specific components
- Maintains proper dependency order

### `.builds.yml`

**Purpose**: Standardized container image building process.

**Details**:
- Builds container images for backend, frontend, and migrations
- Handles image tagging with consistent naming conventions
- Supports multiple tags including PR numbers, environment names, and 'latest'
- Designed to be reusable across different workflows
- Uses the bcgov/action-builder-ghcr action for optimized builds

## Resource Management Workflows

### `pause-resources.yml`

**Trigger**: 
- Schedule (weekdays at 6PM PST)
- Manual workflow dispatch with environment selection
- Workflow call from other workflows

**Purpose**: Cost optimization by pausing resources outside of working hours.

**Inputs**:
- `app_env`: Environment to pause resources for (dev, test, prod, or all)

**Details**:
- Identifies resources that can be safely paused in specified environment(s)
- Scales down ECS services to zero
- Stops RDS clusters
- Uses AWS CLI commands to pause specific services
- Runs on a schedule to automatically pause resources
- Can be targeted to specific environments (dev, test, prod)

### `resume-resources.yml`

**Trigger**: 
- Schedule (weekdays at 7AM PST)
- Manual workflow dispatch with environment selection
- Workflow call from other workflows (like PR deployment)

**Purpose**: Resume paused resources at the start of the working day or on-demand.

**Inputs**:
- `app_env`: Environment to resume resources for (dev, test, prod, or all)

**Details**:
- Starts RDS clusters in specified environment(s)
- Scales ECS services back to their configured capacity
- Ensures all services are in a ready state
- Can be targeted to specific environments (dev, test, prod)

### `prune-env.yml`

**Trigger**: Manual workflow dispatch

**Purpose**: Clean up unused or stale environments to reduce costs.

**Details**:
- Identifies environments that haven't been used recently
- Safely destroys infrastructure for those environments
- Reports on resource cleanup

## Environment Setup

The workflows use the following environment configurations:

1. **Development (dev)**: Used for continuous integration and feature testing
   - Can be deployed manually via workflow dispatch on the PR workflow
   - Serves as the target for merged PRs from the main branch
   - Uses FARGATE_SPOT instances (80%) for cost optimization
   - Auto-scales based on demand with configurable thresholds
   - Resources can be paused/resumed individually for this environment
2. **Testing (test)**: Used for QA and acceptance testing
   - Matches the production configuration for accurate testing
   - Includes database migration execution via Flyway ECS tasks
   - Requires environment approval for resource management operations
   - Can be paused/resumed independently from other environments
3. **Production (prod)**: Used for live production deployments via the release workflow
   - Uses a mix of FARGATE (base=1, 20%) and FARGATE_SPOT (80%) for reliability and cost-effectiveness
   - Database credentials stored and retrieved securely from AWS Secrets Manager
   - API Gateway with VPC Link for secure backend access
   - Requires strict environment approval for resource management operations
   - Can be excluded from automatic pause/resume schedules if needed for 24/7 availability

## Required Secrets

For the workflows to function properly, the following secrets need to be configured:

- `AWS_DEPLOY_ROLE_ARN`: ARN for the IAM role with deployment permissions
- `SONAR_TOKEN_BACKEND`: SonarCloud token for backend analysis
- `SONAR_TOKEN_FRONTEND`: SonarCloud token for frontend analysis
- `AWS_LICENSE_PLATE`: License plate identifier for the AWS environment

## Workflow Diagram

The workflow interactions follow this general pattern:

```
GitHub Event (PR, Push, etc.)
    │
    ├─── PR Open/Update ─────────────────── PR Merge to Main
    │       │                                    │
    │       │                                    ▼
    │       │                              Resume Resources
    │       │                                    │
    │       ├─── Build (calls .builds.yml)       │
    │       │     with concurrency control       │
    │       │                                    │
    │       ├─── Plan Infrastructure             │
    │       │     with concurrency control       │
    │       │                                    │
    │       ├─── Test (calls .tests.yml)         │
    │       │     with concurrency control       │
    │       │                                    ▼
    │       │                                Deploy to Dev
    │       ├─── Manual Workflow Dispatch─┐      │
    │       │                             │      ▼
    │       │                             ▼   Retag Images (dev)
    │       │                        Resume Dev  │
    │       │                             │      ▼
    │       │                             ▼   Run E2E Tests
    │       │                        Deploy to Dev
    │       │                                    │
    │       │                                    ▼
    │       │                              Deploy to Test
    │       │                                    │
    │       │                                    ▼
    │       │                              Retag Images (test)
    │       │                                    │
    │       │                                    ▼
    │       └─── Results                    Pause Resources    │
    └─── Resource Management
            │
            ├─── Pause Resources (Scheduled/Manual/After deployment)
            │     │
            │     ├─── Dev Environment
            │     │
            │     ├─── Test Environment (with approval)
            │     │
            │     └─── Prod Environment (with approval)            │
            ├─── Resume Resources (Scheduled/Manual/Before deployment)
            │     │
            │     ├─── Dev Environment
            │     │
            │     ├─── Test Environment (with approval)
            │     │
            │     └─── Prod Environment (with approval)
            │
            └─── Prune Environments
```

## Best Practices for Workflow Modifications

When customizing these workflows:

1. Maintain the separation of concerns between main and composite workflows
2. Update environment variables consistently across all workflows
3. Test changes thoroughly in isolation before merging
4. Consider impacts on automated resource management
5. Update documentation when changing workflow behavior
6. When using manual workflow dispatch for deployments:
   - Ensure proper resource resume/pause mechanisms are in place
   - Use consistent tagging strategies between PR-based and manual deployments
   - Consider adding validation steps after manual deployments to verify success

## Troubleshooting

Common workflow issues and their solutions:

1. **Failed Authentication**: Ensure AWS role permissions are correctly set
2. **Deployment Failures**: Check Terragrunt outputs for specific error messages
3. **Test Failures**: Review test logs and ensure local tests pass first
