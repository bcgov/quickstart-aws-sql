# GitHub Actions Workflows Guide

This document provides detailed explanations of the GitHub Actions workflows used in this repository. It's designed to help developers understand the CI/CD pipeline structure, the purpose of each workflow, and how they work together to automate the development and deployment process.

## Workflow Categories

The workflows in this repository are organized into three main categories:

1. **Main Workflows**: Primary entry points triggered by GitHub events
2. **Composite Workflows**: Reusable workflow components called by main workflows
3. **Resource Management Workflows**: Specialized workflows for AWS resource management

## Main Workflows

### `pr-open.yml`

**Trigger**: Pull request open or update

**Purpose**: Validates the proposed changes to ensure they meet quality standards and work as expected.

**Steps**:
1. Builds container images for backend, frontend, and migrations, tagging them with the PR number
2. Runs comprehensive tests on the codebase including:
   - Backend unit tests with a PostgreSQL service container
   - Frontend unit tests
   - Security scanning with Trivy
3. SonarCloud analysis for code quality
4. Creates a preview environment (when comments contain `/deploy`)
5. Runs end-to-end tests using Playwright

**Outputs**: Container images tagged with PR number, test results, SonarCloud reports

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

**Trigger**: Push to main branch (merge)

**Purpose**: Creates production-ready resources and deploys to the dev environment.

**Steps**:
1. Determines the PR number that was merged
2. Builds or reuses container images tagged with that PR number
3. Runs tests on the built containers
4. Adds 'latest' tag to container images
5. Deploys the stack to the dev environment using Terragrunt
6. Runs end-to-end tests against the deployed environment

**Outputs**: Deployed application in dev environment, container images with 'latest' tag

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

## Resource Management Workflows

### `pause-resources.yml`

**Trigger**: Schedule (weekdays at 6PM PST) or manual

**Purpose**: Cost optimization by pausing resources outside of working hours.

**Details**:
- Identifies resources that can be safely paused
- Scales down ECS services to zero
- Stops RDS clusters
- Uses AWS CLI commands to pause specific services
- Runs on a schedule to automatically pause resources

### `resume-resources.yml`

**Trigger**: Schedule (weekdays at 6AM PST) or manual

**Purpose**: Resume paused resources at the start of the working day.

**Details**:
- Starts RDS clusters
- Scales ECS services back to their configured capacity
- Ensures all services are in a ready state

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
2. **Testing (test)**: Used for QA and acceptance testing
3. **Production (prod)**: Used for live production deployments

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
    ├─── Main Workflow (pr-open.yml, merge.yml, etc.)
    │       │
    │       ├─── Build
    │       │
    │       ├─── Test (calls .tests.yml)
    │       │
    │       ├─── Deploy (calls .deploy_stack.yml)
    │       │     │
    │       │     └─── Deploy Components (database, api, frontend)
    │       │
    │       └─── Validate (calls .e2e.yml, .load-test.yml)
    │
    └─── Resource Management (scheduled)
            │
            ├─── Pause/Resume Resources
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

## Troubleshooting

Common workflow issues and their solutions:

1. **Failed Authentication**: Ensure AWS role permissions are correctly set
2. **Deployment Failures**: Check Terragrunt outputs for specific error messages
3. **Test Failures**: Review test logs and ensure local tests pass first
