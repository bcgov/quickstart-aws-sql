[![Merge](https://github.com/bcgov/quickstart-aws-containers/actions/workflows/merge.yml/badge.svg)](https://github.com/bcgov/quickstart-aws-containers/actions/workflows/merge.yml)
[![PR](https://github.com/bcgov/quickstart-aws-containers/actions/workflows/pr-open.yml/badge.svg)](https://github.com/bcgov/quickstart-aws-containers/actions/workflows/pr-open.yml)
[![PR Validate](https://github.com/bcgov/quickstart-aws-containers/actions/workflows/pr-validate.yml/badge.svg)](https://github.com/bcgov/quickstart-aws-containers/actions/workflows/pr-validate.yml)
[![CodeQL](https://github.com/bcgov/quickstart-aws-containers/actions/workflows/github-code-scanning/codeql/badge.svg)](https://github.com/bcgov/quickstart-aws-containers/actions/workflows/github-code-scanning/codeql)
[![Pause AWS Resources](https://github.com/bcgov/quickstart-aws-containers/actions/workflows/pause-resources.yml/badge.svg)](https://github.com/bcgov/quickstart-aws-containers/actions/workflows/pause-resources.yml)
[![Resume AWS Resources](https://github.com/bcgov/quickstart-aws-containers/actions/workflows/pause-resources.yml/badge.svg)](https://github.com/bcgov/quickstart-aws-containers/actions/workflows/resume-resources.yml)
# Quickstart for AWS using Aurora Serverless v2, ECS Fargate, and CloudFront

This template repository provides a ready-to-deploy containerized application stack for AWS, developed by BC Government. It includes a complete application architecture with:

- **Aurora Serverless v2** PostgreSQL database with PostGIS extension
- **ECS Fargate** with mixed FARGATE/FARGATE_SPOT capacity providers for cost-optimized backend services
- **Flyway Migrations** automated through ECS tasks for database schema management
- **API Gateway** with VPC link integration for secure backend access
- **CloudFront** for frontend content delivery with WAF protection
- **NestJS** TypeScript backend API with Prisma ORM
- **React** with Vite for the frontend application
- **Terragrunt/Terraform** for infrastructure-as-code deployment
- **GitHub Actions** for CI/CD pipeline automation
- **AWS Secrets Manager** integration for secure credential management

Use this repository as a starting point to quickly deploy a modern, scalable web application on AWS infrastructure.

## Prerequisites

- BCGOV AWS account with appropriate permissions
- AWS CLI installed and configured (for direct AWS account interaction)
- Docker/Podman installed (for local development with containers)
- Node.js 22+ and npm installed (for local development without containers)
- Terraform CLI and Terragrunt (for infrastructure deployment)


# Folder Structure
```
/quickstart-aws-containers
├── CODE_OF_CONDUCT.md        # Project code of conduct
├── COMPLIANCE.yaml           # Compliance and regulatory information
├── CONTRIBUTING.md           # Contribution guidelines
├── docker-compose.yml        # Local development environment definition
├── eslint.config.mjs         # ESLint configuration
├── GHA.md                    # GitHub Actions workflows documentation
├── LICENSE                   # Project license
├── package.json              # Monorepo configuration and dependencies
├── README.md                 # Project documentation
├── renovate.json             # Renovate bot configuration
├── SECURITY.md               # Security policy
├── tsconfig.json             # TypeScript configuration
├── backend/                  # NestJS backend API code
│   ├── Dockerfile            # Container definition for backend service
│   ├── nest-cli.json         # NestJS CLI configuration
│   ├── package.json          # Backend dependencies
│   ├── tsconfig.build.json   # TypeScript build config
│   ├── tsconfig.json         # TypeScript config for backend
│   ├── vitest.config.mts     # Vitest config for backend tests
│   ├── coverage/             # Test coverage reports
│   ├── prisma/               # Prisma ORM schema and migrations
│   │   └── schema.prisma     # Prisma schema definition
│   ├── src/                  # Source code (controllers, services, modules)
│   │   ├── app.controller.spec.ts
│   │   ├── app.controller.ts
│   │   ├── app.module.ts
│   │   ├── app.service.ts
│   │   ├── app.spec.ts
│   │   ├── app.ts
│   │   ├── health.controller.ts
│   │   ├── main.ts
│   │   ├── metrics.controller.ts
│   │   ├── prisma.module.ts
│   │   ├── prisma.service.ts
│   │   ├── prom.ts
│   │   ├── common/           # Common utilities and configs
│   │   ├── middleware/       # Express/NestJS middleware
│   │   └── users/            # User module (controllers, services, DTOs)
│   └── test/                 # Backend test utilities
├── frontend/                 # Vite + React SPA
│   ├── Caddyfile             # Caddy server config for frontend
│   ├── Dockerfile            # Container definition for frontend service
│   ├── index.html            # Main HTML entry point
│   ├── package.json          # Frontend dependencies
│   ├── playwright.config.ts  # Playwright E2E test config
│   ├── tsconfig.json         # TypeScript config for frontend
│   ├── tsconfig.node.json    # Node-specific TypeScript config
│   ├── vite.config.ts        # Vite build config
│   ├── vitest.config.ts      # Vitest config for frontend tests
│   ├── e2e/                  # End-to-end tests using Playwright
│   │   ├── qsos.spec.ts
│   │   ├── pages/            # Page objects for E2E tests
│   │   └── utils/            # E2E test utilities
│   ├── public/               # Static assets
│   ├── src/                  # React source code
│   │   ├── index.css
│   │   ├── main.tsx
│   │   ├── routeTree.gen.ts
│   │   ├── test-setup.ts
│   │   ├── test-utils.tsx
│   │   ├── __tests__/        # Frontend unit tests
│   │   ├── assets/           # Images and static assets
│   │   ├── components/       # React components
│   │   ├── interfaces/       # TypeScript interfaces
│   │   ├── routes/           # Route definitions
│   │   ├── scss/             # SCSS styles
│   │   └── service/          # API and service logic
├── infra/                    # Terraform code for AWS infrastructure
│   ├── main.tf               # Infrastructure root module
│   ├── outputs.tf
│   ├── providers.tf
│   ├── variables.tf
│   └── modules/              # Infrastructure modules
│       ├── api/              # API infrastructure (ECS, ALB, etc.)
│       ├── database/         # Database infrastructure (Aurora, etc.)
│       └── frontend/         # Frontend infrastructure (CloudFront, etc.)
├── migrations/               # Flyway migrations for database
│   ├── Dockerfile            # Container for running migrations
│   └── sql/                  # SQL migration scripts
│       └── V1.0.0__init.sql
├── terragrunt/               # Terragrunt configuration for environments
│   ├── terragrunt.hcl        # Root Terragrunt config
│   ├── dev/
│   │   └── terragrunt.hcl    # Dev environment config
│   ├── prod/
│   │   └── terragrunt.hcl    # Prod environment config
│   └── test/
│       └── terragrunt.hcl    # Test environment config
├── tests/                    # Test suites beyond component-level
│   └── integration/          # Integration tests across services
│       ├── package.json
│       └── src/
│           ├── load/         # Load testing scripts
│           │   ├── backend-test.js
│           │   ├── frontend-test.js
│           │   └── README.md
```

## Repository Structure Explained

- **.github/**: Contains GitHub workflow definitions and actions for the CI/CD pipeline.
  - **workflows/**: GitHub Actions workflow files that handle automated testing, deployment, and resource management.

- **terragrunt/**: Contains Terragrunt configuration files that orchestrate the infrastructure deployment.
  - Environment-specific folders (`dev`, `test`) contain configurations for different deployment stages.
  - Uses the infrastructure modules defined in the infrastructure directory.

**infra/**: Contains Terraform code and modules for AWS infrastructure components.
  - **api/**: ECS Fargate backend API infrastructure (ALB, API Gateway, autoscaling, IAM, Secrets Manager, Flyway migration task)
  - **frontend/**: CloudFront distribution and WAF for frontend content delivery
  - **database/**: Aurora Serverless v2 PostgreSQL database and networking

- **backend/**: NestJS backend application with TypeScript.
  - **src/**: Application code organized by feature modules.
  - **prisma/**: Database ORM schema definitions and connection handling.
  - Includes testing infrastructure and containerization setup.

- **frontend/**: React-based single-page application built with Vite.
  - **src/**: React components and application logic.
  - **e2e/**: End-to-end tests with Playwright for UI validation.
  - Includes deployment configuration for AWS.

- **migrations/**: Flyway database migration scripts and configuration.
  - **sql/**: SQL scripts for schema evolution that Flyway executes in order.

- **tests/**: Cross-component test suites to validate the application at a higher level.
  - **integration/**: Tests validating interactions between services.
  - **load/**: Performance testing scripts to ensure scalability.

- **docker-compose.yml**: Defines the local development environment with all services.

- **package.json**: Monorepo configuration for shared tooling like ESLint and Prettier.

# Running Locally
## Running Locally with Docker Compose

To run the entire stack locally using the `docker-compose.yml` file in the root directory, follow these steps:

1. Ensure Docker (or Podman) is installed and running on your machine.
2. Navigate to the root directory of the project:
    ```sh
    cd <checkedout_repo_dir>
    ```
3. Build and start the containers:
    ```sh
    docker-compose up --build
    ```
4. The backend API should now be running at `http://localhost:3001` and the frontend at `http://localhost:3000`.

To stop the containers, press `Ctrl+C` in the terminal where `docker-compose` is running, or run:
```sh
docker-compose down
```
## Running Locally without Docker (Complex)
Prerequisites:

    1. Install JDK 17 and above.
    2. Install Node.js 22 and above.
    3. Install Postgres 17.4 with Postgis extension.
    4. Download flyway.jar file
Once all the softwares are installed follow below steps.

1. Run Postgres DB (better as a service on OS).
2. Run flyway migrations (this needs to be run everytime changes to migrations folder happen)
```sh
java -jar flyway.jar -url=jdbc:postgresql://$posgtres_host:5432/$postgres_db -user=$POSTGRES_USER -password=$POSTGRES_PASSWORD -baselineOnMigrate=true -schemas=$FLYWAY_DEFAULT_SCHEMA migrate
```
3. Run backend from root of folder.
```sh
cd backend
npm run start:dev or npm run start:debug
```
4. Run Frontend from root of folder.
```sh
cd frontend
npm run dev
```

# Deploying to AWS

This repository uses a Terraform/Terragrunt approach for deploying to AWS, with automated workflows through GitHub Actions.

## Deployment Options

### Option 1: GitHub Actions CI/CD Pipeline (Recommended)

The repository includes pre-configured GitHub Actions workflows that handle:
- Building and testing changes on pull requests
- Deploying to AWS environments on merge to specific branches
- Resource management (pausing/resuming)
- Automated testing including unit tests, integration tests, and load tests
- Security scanning with Trivy

To use the CI/CD pipeline:

1. Fork or clone this repository
2. Configure the required GitHub secrets (see below)
3. Push changes to trigger the appropriate workflows

Required GitHub secrets:
- `AWS_ROLE_TO_ASSUME` - IAM role ARN with deployment permissions
- `SONAR_TOKEN_BACKEND` - For SonarCloud analysis of backend code
- `SONAR_TOKEN_FRONTEND` - For SonarCloud analysis of frontend code
- `AWS_LICENSE_PLATE` - The license plate without env(-dev or -test) provided from OCIO when creating namespace

### Option 2: Manual Terraform Deployment

1. Configure your AWS credentials locally
2. Navigate to the terraform directory
3. Run Terragrunt commands for the desired environment

```sh
cd terraform/api/dev
terragrunt init
terragrunt plan
terragrunt apply
```

For detailed deployment instructions, refer to the [AWS deployment setup guide](https://github.com/bcgov/quickstart-aws-helpers/blob/main/AWS-DEPLOY.md).

# CI/CD Workflows

This repository includes sophisticated GitHub Actions workflows for continuous integration and deployment.

## Pull Request Workflow
![Pull Request Workflow](./.github/graphics/pr-open.jpg)

When a pull request is opened:
1. Code is built with concurrency control to prevent overlapping operations
2. Infrastructure changes are planned with Terraform/Terragrunt
3. Comprehensive tests are run in isolated environments with concurrency control
4. Security scans are performed with Trivy for vulnerability detection
5. SonarCloud analysis runs for both frontend and backend code quality
6. A review environment can be created manually via workflow dispatch

## Merge Workflow
![Merge](./.github/graphics/merge.jpg)

When code is merged to the main branch:
1. AWS resources are automatically resumed across all environments
2. The application is deployed to the dev environment
3. Container images are tagged with the 'dev' tag
4. End-to-end tests verify functionality against the dev environment
5. Upon successful testing, deployment progresses to the test environment
6. Container images are tagged with the 'test' tag
7. AWS resources are paused after deployment to optimize costs

## GitHub Actions Workflows Overview

The repository includes a comprehensive set of GitHub Actions workflows that automate the entire development lifecycle. These workflows are organized into three categories:

### Main Workflows
- **PR Workflows**: Triggered when pull requests are opened, updated, or closed
  - `pr-open.yml`: Builds containers with concurrency control, runs tests, and provides validation for new PRs
  - `pr-validate.yml`: Ensures code quality and standards compliance
  - `pr-close.yml`: Cleans up resources when PRs are closed
- **Deployment Workflows**: Handle the deployment pipeline
  - `merge.yml`: Resumes resources, deploys to dev and test environments, and then pauses resources
  - `release.yml`: Creates releases and deploys to production (manually triggered)

### Composite Workflows
- **Building**: `.builds.yml` 
- **Testing**: `.tests.yml`, `.e2e.yml`, `.load-test.yml`
- **Deployment**: `.deploy_stack.yml`, `.destroy_stack.yml`, `.deployer.yml`, `.stack-prefix.yml`

### Resource Management
- **Cost Optimization**: 
  - `pause-resources.yml`: Pauses resources in specified environments (dev/test/prod) either on schedule, manually, or automatically after deployment
  - `resume-resources.yml`: Resumes resources in specified environments either on schedule, manually, or automatically before deployment
- **Workflow Integration**:
  - Resources are automatically resumed before deployments in the merge workflow
  - Resources are automatically paused after successful deployments to save costs
  - Individual environment targeting allows for selective resource management
- **Cleanup**: `prune-env.yml`

For detailed documentation on all GitHub Actions workflows, including their triggers, purposes, steps, and outputs, see the [GitHub Actions Workflows Guide](./GHA.md).

## Architecture
![Architecture](./.diagrams/arch.drawio.svg)

### Infrastructure Components

#### ECS Fargate Configuration
- **Mixed Capacity Strategy**: Uses both FARGATE (20% weight with base=1) and FARGATE_SPOT (80% weight) for cost optimization
- **Auto-Scaling**: Configures automatic scaling based on CPU and memory utilization:
  - Scales up aggressively (by 2 instances) when thresholds are exceeded
  - Scales down conservatively (by 1 instance) when resources are underutilized
- **Task Definitions**:
  - Flyway migration task that runs before application deployment
  - Backend API task with PostgreSQL environment variables
- **Secrets Management**: Securely retrieves database credentials from AWS Secrets Manager

#### API Gateway
- HTTP API Gateway with VPC Link integration
- Routes all traffic to the internal Application Load Balancer
- Supports ANY method with proxy path integration

#### Database Integration
- Automatically connects to Aurora PostgreSQL using endpoint discovery
- Uses master credentials stored in Secrets Manager
- Applies schema migrations using Flyway in a dedicated ECS task
- Supports read/write splitting with separate endpoints for read-only operations

# Customizing the Template

To adapt this template for your own project:

1. **Repository Setup**
   - Clone this repository
   - Update project names in package.json files
   - Set up required GitHub secrets

2. **Infrastructure Customization**
   - Modify `terraform` and `infrastructure` directories to adjust resource configurations
   - Update environment-specific variables for your needs
   - Adjust ECS task definitions in `infrastructure/api/ecs.tf`:
     - Customize container resources (CPU/memory) based on your application needs
     - Modify auto-scaling thresholds in `infrastructure/api/autoscaling.tf`
     - Update capacity provider strategy for cost-optimization vs. reliability balance
   - Configure database connection parameters and schema information
   - Customize API Gateway and VPC link settings in `infrastructure/api/api-gateway.tf`

3. **Application Customization**
   - Customize the NestJS backend in the `backend` directory
   - Adapt the React frontend in the `frontend` directory
   - Update database schema and migrations in `migrations/sql`

4. **CI/CD Pipeline Adjustments**
   - Modify GitHub workflows in `.github/workflows` as needed
   - Update deployment configuration to match your AWS account structure
   - Configure resource management workflows (pause/resume) to match your schedule:
     - Adjust cron schedules for automatic pausing/resuming based on your working hours
     - Set up environment-specific resource management for cost optimization
     - Customize protection rules for production environments

5. **Testing**
   - Adapt existing tests to match your application logic in each component:
     - Backend unit tests using Vitest in the `backend/src` directory
     - Frontend unit tests in the `frontend/src/__tests__` directory
     - End-to-end tests using Playwright in the `frontend/e2e` directory
     - Load tests using k6 in the `tests/load` directory
   - Configure SonarCloud for code quality analysis by updating the project keys
   - Adjust GitHub workflow test runners as needed for your specific environments

# Contributing

Contributions to this quickstart template are welcome! Please see our [CONTRIBUTING.md](CONTRIBUTING.md) file for details on how to contribute.
