# How To Deploy to AWS using Terraform

## Prerequisites

1. BCGov AWS account/namespace, make sure you have access provided from PO, [follow this link](https://dev.developer.gov.bc.ca/docs/default/component/public-cloud-techdocs/aws/LZA/design-build-deploy/user-management/#managing-security-group-membership)
2. AWS CLI installed.
3. Github CLI (optionally installed).

## Execute the bash script for the initial setup for each AWS environment (dev, test, prod)
1. [Login to console via IDIR MFA](https://bcgov.awsapps.com/start/#/?tab=accounts)
2. click on `Access Keys` for the namespace and copy the information and paste it into your bash terminal, then run following commands.
```bash
chmod +x aws-initial-pipeline-setup.sh
./aws-initial-pipeline-setup.sh
```
