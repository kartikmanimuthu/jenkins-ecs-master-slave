# AWS ECS Deployment Details

This section details the deployment of the Jenkins master-slave architecture on AWS ECS using Terraform. The setup leverages various AWS services to provide a robust, scalable, and persistent Jenkins environment.

## Architecture Components:

- **Jenkins Master ECS Service**: Runs on AWS Fargate with a single task. This service hosts the main Jenkins server.
- **Jenkins Agent ECS Service**: Runs on AWS Fargate with multiple tasks (initially 2). These tasks act as Jenkins agents, executing build jobs.
- **ECR Repositories**: Separate Amazon Elastic Container Registry (ECR) repositories are used to store Docker images for both the Jenkins Master and Agent.
- **EFS Storage**: Amazon Elastic File System (EFS) is used for persistent storage of Jenkins data, ensuring that configurations, job history, and plugins are preserved even if the master task is restarted or replaced.
- **ALB Load Balancer**: An Application Load Balancer (ALB) is configured to provide external access to the Jenkins web interface, distributing incoming traffic to the Jenkins Master ECS service.
- **Security Groups**: Network security groups are meticulously configured to allow necessary communication between the Jenkins Master, Agents, and the ALB, while restricting unauthorized access.
- **CloudWatch Logging**: All service logs are directed to AWS CloudWatch for centralized logging, monitoring, and troubleshooting.

## Deployment Process (Terraform):

The entire infrastructure is provisioned and managed using Terraform. The deployment typically involves:

1. **VPC and Networking**: Setting up a Virtual Private Cloud (VPC), subnets, route tables, and internet gateways to provide a secure and isolated network environment.
2. **ECS Cluster**: Creating an ECS cluster where the Jenkins Master and Agent services will run.
3. **ECR Repositories**: Defining and creating the ECR repositories for Docker images.
4. **EFS File System**: Provisioning the EFS file system and mount targets for persistent storage.
5. **IAM Roles and Policies**: Configuring appropriate AWS Identity and Access Management (IAM) roles and policies for ECS tasks to interact with other AWS services securely.
6. **ECS Task Definitions**: Defining the specifications for Jenkins Master and Agent tasks, including Docker image, CPU, memory, port mappings, and EFS volume mounts.
7. **ECS Services**: Creating ECS services to maintain the desired number of tasks for the Master and Agent, ensuring high availability.
8. **ALB Configuration**: Setting up the Application Load Balancer, target groups, and listener rules to route traffic to the Jenkins Master.

## Key Considerations:

- **Fargate**: Utilizing Fargate eliminates the need to manage EC2 instances for the ECS cluster, simplifying infrastructure management.
- **Scalability**: The ECS services can be configured for auto-scaling based on demand, allowing the Jenkins environment to scale dynamically.
- **Persistence**: EFS ensures that Jenkins data is persistent, which is crucial for a stateful application like Jenkins.

This Terraform-based approach provides an automated, repeatable, and version-controlled way to deploy and manage the Jenkins infrastructure on AWS.
