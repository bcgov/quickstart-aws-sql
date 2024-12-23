# quickstart-aws-containers
⚠️ This is very much in WIP phase. Though the code and workflows can be used to deploy to AWS⚠️

## Prerequisites

- BCGOV AWS account with appropriate permissions
- AWS CLI installed and configured (If interaction with AWS account is preferred)
- Docker/Podman installed (To run database and flyway migrations or whole stack)
- Node.js and npm installed (If not using docker compose for whole stack, to run backend and frontend)


# Folder Structure
```
/quickstart-aws-containers
├── .github/                   # GitHub workflows and actions
├── terraform/                 # Terragrunt configuration files
├── infrastructure/            # Terraform code for each component
│   ├── api/                   # API(ECS) related terraform code(backend)
│   ├── frontend/              # Cloudfront with WAF
│   ├── database/              # Aurora RDS database
├── backend/                   # Node Nest express backend API code
├── frontend/                  # Vite + React SPA
├── migrations/                # Flyway Migrations scripts to run database schema migrations
├── docker-compose.yml         # Docker compose file
├── README.md                  # Project documentation
└── package.json               # Node.js monorepo for eslint and prettier
```

- **.github/**: Contains GitHub workflows and actions for CI/CD.
- **terraform/**: Contains Terragrunt configuration files.
- **infrastructure/**: Contains Terraform code for each component.
    - **api/**: Contains Terraform code for the backend API (ECS).
    - **frontend/**: Contains Terraform code for Cloudfront with WAF.
    - **database/**: Contains Terraform code for Aurora RDS database.
- **backend/**: Contains Node Nest express backend API code.
- **frontend/**: Contains Vite + React SPA code.
- **docker-compose.yml**: Docker compose file for local development.
- **README.md**: Project documentation.
- **package.json**: Node.js monorepo configuration for eslint and prettier.

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

# Deploying to AWS
1. Please follow the wiki link for AWS deployment [setup](https://github.com/bcgov/quickstart-aws-containers/wiki/Deploy-To-AWS-Using-Terraform)

## Pull Request Workflow
```mermaid
graph LR
  A[Pull Request] --> B{Check Permissions}
  B --> C{Checkout Code}
  B --> D{Build Images}
    D --> E{backend}
    D --> F{migrations}
    D --> G{frontend}
  C --> H{Plan Database}
  H --> I{Plan API} [Needs Database Plan]
  I --> J{Plan Cloudfront} [Needs API Plan]
  D --> K{Tests} [Needs Built Images]
  H,I,J,K --> L{PR Results}
  L --> M{Failure} [At least one job failed]
  L --> N{Success}
```
## Merge to main Workflow
```mermaid
graph LR
  A[Push to Main] --> B{Check Event}
  B --> C{Use PR number from Workflow Dispatch} [workflow_dispatch]
  B --> D{Get PR number from Merge} [push to main]
  C,D --> E{Set Variables}
  E --> F{Deploy Database} [Needs: Set Variables]
  F --> G{Deploy API} [Needs: Deploy Database, Set Variables]
    G --> H{Build UI} [Needs: Deploy API, Deploy Cloudfront]
  F --> I{Deploy Cloudfront} [Needs: Set Variables]
  H --> J{Checkout Code}
  H --> K{Setup Node.js}
  H --> L{Configure AWS Credentials}
  J,K,L --> M{Build and Update UI}
    M --> N{Sync to S3}
    M --> O{Invalidate Cloudfront Cache}
```