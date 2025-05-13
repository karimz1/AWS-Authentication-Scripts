# 📄 Required IAM Roles

## 🛠️ Script: `refreshEcrDockerToken.ps1`

To execute this script securely and effectively, the following IAM roles or policies must be attached to the AWS identity (user or role) executing the script. I've used Minimal required roles, for security!

------

### 🔐 Role 1: `ECR_Script_Minimal_Role`

This role grants basic permissions to identify the caller and interact with AWS CodeArtifact listing APIs.
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowListingCodeArtifactDomains",
            "Effect": "Allow",
            "Action": "codeartifact:ListDomains",
            "Resource": "*"
        },
        {
            "Sid": "AllowGettingCallerIdentity",
            "Effect": "Allow",
            "Action": "sts:GetCallerIdentity",
            "Resource": "*"
        }
    ]
}
```

------

### 🔐 Role 2: `ECR Pull Role`

This role provides the necessary permissions to authenticate with Amazon ECR and pull Docker images.

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "ECRPull",
            "Effect": "Allow",
            "Action": [
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetAuthorizationToken"
            ],
            "Resource": "*"
        }
    ]
}
```


## 📌 Disclaimer

-- All given without warranty. It worked for me.

— Karim Zouine