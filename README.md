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