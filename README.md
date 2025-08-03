# Jenkins on ECS Deployment

This Terraform project deploys a Jenkins server on AWS ECS (Elastic Container Service) using Fargate launch type. The deployment includes all necessary resources such as VPC, EFS for persistent storage, ALB for load balancing, security groups, and IAM roles. The project uses a modular approach with the core-tf-mod-vpc module to create and manage all networking resources.

## Architecture Overview

This project deploys a Jenkins master-slave architecture on AWS ECS using Fargate. The diagram below provides a high-level overview of the deployed components and their interactions.

![High-Level Jenkins on AWS ECS Architecture](docs/jenkins_on_aws_ecs.png)

For a detailed explanation of the architecture, including the Jenkins master-slave concept, JNLP communication, and AWS ECS deployment specifics, please refer to the [detailed documentation in the `docs` folder](docs/index.md).

## Security Features

- IAM roles follow the principle of least privilege
- SSL/TLS for HTTPS access via ALB
- VPC security groups control network access
- EFS encryption at rest
- Auto-generated secure Jenkins admin password stored in AWS Parameter Store
- KMS encryption for sensitive data

## Prerequisites

- AWS CLI configured with appropriate permissions
- Terraform v1.0.0 or newer
- S3 bucket for Terraform state
- DynamoDB table for state locking
- ACM certificate for HTTPS
- SSM Parameter Store for Jenkins admin password

## Setup Instructions

1. **Configure Terraform backend**:

Create a file named `backend.tfvars` with your S3 bucket details:

```
bucket         = "your-terraform-state-bucket"
key            = "tf-smc-jenkins-bod/terraform.tfstate"
region         = "ap-south-1"
encrypt        = true
dynamodb_table = "terraform-lock"
```

2. **Configure deployment variables**:

Copy the example variables file and customize it:

```bash
cp example.tfvars terraform.tfvars
```

Edit `terraform.tfvars` with your specific values for VPC CIDR, domain name, etc. The VPC and subnets will be automatically created by the core-tf-mod-vpc module.

3. **Initialize Terraform**:

```bash
terraform init -backend-config=backend.hcl
```

4. **Plan and apply the deployment**:

Then run the Terraform commands:

```bash
terraform plan
terraform apply
```

## Credential Management

This module implements secure credential handling with AWS Systems Manager Parameter Store:

1. **Automated Generation**: Jenkins admin credentials (both username and password) are automatically generated during deployment

   - Username is set to `admin` by default
   - Password is a 16-character secure random string with special characters

2. **Secure Storage**: Credentials are stored in AWS SSM Parameter Store

   - Username: `${var.jenkins_admin_password_ssm_parameter}/username` (stored as plain text)
   - Password: `${var.jenkins_admin_password_ssm_parameter}/password` (stored as SecureString with KMS encryption)
   - Parameter paths default to `/jenkins/admin/username` and `/jenkins/admin/password`

3. **Secure Access**: The Jenkins ECS task has an IAM policy allowing it to read these parameters

## Post-Deployment Steps

1. Access the Jenkins UI using the ALB URL or domain name at `https://your-domain-name/jenkins`
2. Retrieve the login credentials using AWS CLI:

   ```bash
   # Get username
   aws ssm get-parameter --name /jenkins/admin/username --query Parameter.Value --output text

   # Get password (with decryption)
   aws ssm get-parameter --name /jenkins/admin/password --with-decryption --query Parameter.Value --output text
   ```

3. Log in to Jenkins using these credentials
4. The login credentials are also available in the Terraform outputs

## Access Jenkins

After successful deployment, you can access Jenkins using the URL provided in the outputs:

```bash
terraform output jenkins_url
```

Use the admin password you configured in SSM Parameter Store for the initial login.

## Maintenance

### Updating Jenkins

To update the Jenkins version, modify the `jenkins_image` variable and apply the changes:

```bash
terraform apply -var="jenkins_image=jenkins/jenkins:newer-version"
```

### Scaling

The deployment uses Fargate, which can be scaled by adjusting the CPU and memory allocations in the variables:

```
jenkins_container_cpu    = 2048  # 2 vCPU
jenkins_container_memory = 4096  # 4GB RAM
```

## Security Considerations

- Access to Jenkins is controlled by the `allowed_cidr_blocks` variable
- HTTPS is enforced with redirect from HTTP
- Jenkins data is stored in an encrypted EFS volume
- Credentials are managed through SSM Parameter Store
- ECS tasks run in private subnets

## Notes

- The ALB has deletion protection enabled. To delete it, set `enable_deletion_protection = false` in the ALB module configuration in compute.tf
- Jenkins plugins can be pre-installed by customizing the Docker image
- For production use, consider implementing Jenkins Configuration as Code (JCasC)
- The direct image reference approach avoids ECR image URI duplication issues
- Security groups include ICMP access rules for internal network monitoring
- ALB listener rules use explicit priority settings (priority = 1) for better manageability

## Acknowledgements

This Terraform project is inspired by and builds upon the valuable work of Tom Gregory, particularly his guide on [Deploying Jenkins into AWS ECS](https://tomgregory.com/jenkins/deploy-jenkins-into-aws-ecs/#launching-the-cloudformation-stack-in-your-aws-account). We extend our sincere thanks for his foundational insights.
