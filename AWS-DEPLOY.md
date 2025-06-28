# How To Deploy to AWS using Terraform

## Prerequisites

1. BCGov AWS account/namespace.
2. AWS CLI installed.
3. Github CLI (optionally installed).

## Execute the bash script for the initial setup for each AWS environment (dev, test, prod)
1. [Login to console via IDIR MFA](https://login.nimbus.cloud.gov.bc.ca/)
2. click on `Click for Credentials` for the namespace and copy the information and paste it into your bash terminal, then run following commands.
```bash
chmod +x aws-initial-pipeline-setup.sh
./aws-initial-pipeline-setup.sh
```
