[![Merge](https://github.com/bcgov/quickstart-aws-containers/actions/workflows/merge.yml/badge.svg)](https://github.com/bcgov/quickstart-aws-containers/actions/workflows/merge.yml)
[![PR](https://github.com/bcgov/quickstart-aws-containers/actions/workflows/pr-open.yml/badge.svg)](https://github.com/bcgov/quickstart-aws-containers/actions/workflows/pr-open.yml)
[![PR Validate](https://github.com/bcgov/quickstart-aws-containers/actions/workflows/pr-validate.yml/badge.svg)](https://github.com/bcgov/quickstart-aws-containers/actions/workflows/pr-validate.yml)
[![CodeQL](https://github.com/bcgov/quickstart-aws-containers/actions/workflows/github-code-scanning/codeql/badge.svg)](https://github.com/bcgov/quickstart-aws-containers/actions/workflows/github-code-scanning/codeql)
[![Pause AWS Resources](https://github.com/bcgov/quickstart-aws-containers/actions/workflows/pause-resources.yml/badge.svg)](https://github.com/bcgov/quickstart-aws-containers/actions/workflows/pause-resources.yml)
[![Pause AWS Resources](https://github.com/bcgov/quickstart-aws-containers/actions/workflows/pause-resources.yml/badge.svg)](https://github.com/bcgov/quickstart-aws-containers/actions/workflows/pause-resources.yml)
# Quickstart for AWS using Aurora Serverless v2, ECS Fargate, and CloudFront

This template repository provides a ready-to-deploy containerized application stack for AWS, developed by BC Government. It includes a complete application architecture with:

- **Aurora Serverless v2** PostgreSQL database with PostGIS extension
- **ECS Fargate** for containerized backend services
- **CloudFront** for frontend content delivery with WAF protection
- **NestJS** TypeScript backend API
- **React** with Vite for the frontend application
- **Terragrunt/Terraform** for infrastructure-as-code deployment
- **GitHub Actions** for CI/CD pipeline automation

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
├── .github/                   # GitHub workflows and actions for CI/CD
│   └── workflows/             # GitHub Actions workflow definitions
├── terraform/                 # Terragrunt configuration files for environment management
│   ├── api/                   # API environment-specific configurations (dev, test)
│   ├── database/              # Database environment-specific configurations (dev, test)
│   └── frontend/              # Frontend environment-specific configurations (dev, test)
├── infrastructure/            # Terraform code for each AWS infrastructure component
│   ├── api/                   # ECS Fargate API configuration (ALB, API Gateway, autoscaling)
│   ├── frontend/              # CloudFront with WAF configuration
│   └── database/              # Aurora Serverless v2 PostgreSQL configuration
├── backend/                   # NestJS backend API code
│   ├── src/                   # Source code with controllers, services, and modules
│   ├── prisma/                # Prisma ORM schema and migrations
│   └── Dockerfile             # Container definition for backend service
├── frontend/                  # Vite + React SPA
│   ├── src/                   # React components, routes, and services
│   ├── e2e/                   # End-to-end tests using Playwright
│   └── Dockerfile             # Container definition for frontend service
├── migrations/                # Flyway migrations for database schema management
│   └── sql/                   # SQL migration scripts
├── tests/                     # Test suites beyond component-level tests
│   ├── integration/           # Integration tests across services
│   └── load/                  # Load testing scripts for performance testing
├── docker-compose.yml         # Local development environment definition
├── README.md                  # Project documentation
└── package.json               # Node.js monorepo for shared configurations
```

## Repository Structure Explained

- **.github/**: Contains GitHub workflow definitions and actions for the CI/CD pipeline.
  - **workflows/**: GitHub Actions workflow files that handle automated testing, deployment, and resource management.

- **terraform/**: Contains Terragrunt configuration files that orchestrate the infrastructure deployment.
  - Environment-specific folders (`dev`, `test`) contain configurations for different deployment stages.
  - Uses the infrastructure modules defined in the infrastructure directory.

- **infrastructure/**: Contains Terraform modules for each AWS component.
  - **api/**: Defines ECS Fargate cluster, Application Load Balancer, API Gateway, autoscaling policies, IAM roles, and networking.
  - **frontend/**: Sets up CloudFront distribution with WAF rules for content delivery.
  - **database/**: Configures Aurora Serverless v2 PostgreSQL database with networking.

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
    3. Install Postgres 16.4 with Postgis extension.
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

For detailed deployment instructions, refer to the [AWS deployment setup guide](https://github.com/bcgov/quickstart-aws-containers/wiki/Deploy-To-AWS-Using-Terraform).

# CI/CD Workflows

This repository includes sophisticated GitHub Actions workflows for continuous integration and deployment.

## Pull Request Workflow
![Pull Request Workflow](./.github/graphics/pr-open.jpg)

When a pull request is opened:
1. Code is tested and validated using test runners in isolated environments
2. Security scans are performed with Trivy for vulnerability detection
3. SonarCloud analysis runs for both frontend and backend code quality
4. A review environment can be created automatically for testing
5. End-to-end tests verify functionality across the entire stack

## Merge Workflow
![Merge](./.github/graphics/merge.jpg)

When code is merged to the main branch:
1. Containers are built and tagged with appropriate version numbers
2. Comprehensive tests run against the built containers
3. Infrastructure is updated or created via Terraform/Terragrunt
4. New application versions are deployed to the target environment

## GitHub Actions Workflows Overview

The repository includes a comprehensive set of GitHub Actions workflows that automate the entire development lifecycle. These workflows are organized into three categories:

### Main Workflows
- **PR Workflows**: Triggered when pull requests are opened, updated, or closed
  - `pr-open.yml`: Builds containers, runs tests, and provides validation for new PRs
  - `pr-validate.yml`: Ensures code quality and standards compliance
  - `pr-close.yml`: Cleans up resources when PRs are closed
- **Deployment Workflows**: Handle the deployment pipeline
  - `merge.yml`: Deploys to development environment when changes are merged to main
  - `release.yml`: Creates releases and deploys to production (manually triggered)

### Composite Workflows
- **Testing**: `.tests.yml`, `.e2e.yml`, `.load-test.yml`
- **Deployment**: `.deploy_stack.yml`, `.destroy_stack.yml`, `.deployer.yml`, `.stack-prefix.yml`

### Resource Management
- **Cost Optimization**: `pause-resources.yml`, `resume-resources.yml`
- **Cleanup**: `prune-env.yml`

For detailed documentation on all GitHub Actions workflows, including their triggers, purposes, steps, and outputs, see the [GitHub Actions Workflows Guide](./GHA.md).

## Architecture
![Architecture](./.diagrams/arch.drawio.svg)

# Customizing the Template

To adapt this template for your own project:

1. **Repository Setup**
   - Clone this repository
   - Update project names in package.json files
   - Set up required GitHub secrets

2. **Infrastructure Customization**
   - Modify `terraform` and `infrastructure` directories to adjust resource configurations
   - Update environment-specific variables for your needs

3. **Application Customization**
   - Customize the NestJS backend in the `backend` directory
   - Adapt the React frontend in the `frontend` directory
   - Update database schema and migrations in `migrations/sql`

4. **CI/CD Pipeline Adjustments**
   - Modify GitHub workflows in `.github/workflows` as needed
   - Update deployment configuration to match your AWS account structure
   - Configure resource management workflows (pause/resume) to match your schedule

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
