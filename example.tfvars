# ======================
# Jenkins ECS Master-Slave Configuration (Example)
# ======================
# Copy this file to terraform.tfvars and update the values
# DO NOT commit terraform.tfvars to version control

# ======================
# Infrastructure Configuration
# ======================

# VPC Configuration
vpc_cidr           = "10.255.0.0/16"
enable_nat_gateway = true
aws_region         = "ap-south-1"

# EFS Configuration
enable_efs_backup = false
# create_intra_subnets   = false
# create_database_subnets = false

# Security Configuration
# whitelisted_ip_addresses = ["10.0.0.0/8", "192.168.0.0/16"]
# Replace with your ACM certificate ARN
load_balancer_ssl_certificate_arn = "arn:aws:acm:ap-south-1:ACCOUNT_ID:certificate/XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"

# Encryption Configuration
# Replace with your KMS key ARN and alias
kms_key_arn   = "arn:aws:kms:ap-south-1:ACCOUNT_ID:key/XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"
kms_alias_arn = "arn:aws:kms:ap-south-1:ACCOUNT_ID:alias/your-kms-alias"

# ======================
# Jenkins Configuration
# ======================
enable_https                  = true
enable_http_https_redirection = true
jenkins_domain                = "jenkins.example.com"

# Jenkins Container Configuration
jenkins_image                        = "jenkins/jenkins:lts-jdk17"
logs_retention_in_days               = 30
jenkins_admin_password_ssm_parameter = "/jenkins/admin/password"

# ======================
# Project Configuration
# ======================
environment  = "dev" # Options: dev, qa, uat, prod
OU           = "OU"
BU           = "BU"
PU           = "PU"
project_name = "project_name"


# ======================
# Resource Tags
# ======================
tags = {
  Owner       = "Owner"
  Environment = "Environment"
  ManagedBy   = "ManagedBy"
  Project     = "Project"
}
