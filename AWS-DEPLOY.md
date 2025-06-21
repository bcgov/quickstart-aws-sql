# How To Deploy to AWS using Terraform

## Prerequisites

1. BCGov AWS account/namespace.

## Steps to be taken in the console(UI) to setup the secret in github for terraform deployment

1. [Login to console via IDIR MFA](https://login.nimbus.cloud.gov.bc.ca/)
2. Navigate to IAM, click on policies on left hand menu.
3. Click on `Create policy` button and switch from visual to JSON then paste the below snippet

```json
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
```
4. Then create a role by clicking `create role` button and then selecting (custom trust policy radio button).
5. Paste the below JSON after making modifications to set trust relationships of the role with your github repo(<repo_name> ex: bcgov/quickstart-aws-containers) .

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "arn:aws:iam::<account_number>:oidc-provider/token.actions.githubusercontent.com"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringLike": {
                    "token.actions.githubusercontent.com:sub": "repo:<repo_name>:*"
                },
                "ForAllValues:StringEquals": {
                    "token.actions.githubusercontent.com:aud": "sts.amazonaws.com",
                    "token.actions.githubusercontent.com:iss": "https://token.actions.githubusercontent.com"
                }
            }
        }
    ]
}
```
6. Click on Next button, then add the policies after searching for it and then enabling it by checking the checkbox.
7. Finally give a role name for ex: `GHA_CI_CD` and then click on `create role` button.
7. After the role is created copy the ARN, it would be like `arn:aws:iam::<account_number>:role/<role_name>` , `role_name` is what was created on step 4.
8. Paste this value into github secrets, repository secret or environment secret based on your needs. The key to use is `AWS_DEPLOY_ROLE_ARN`
9. Paste the license plate value( 6 alphanumeric characters ex: `ab9okj`) without the env as a repository secret. The Key to use is `AWS_LICENSE_PLATE`
10. After this the github action workflows would be able to deploy the stack to AWS.