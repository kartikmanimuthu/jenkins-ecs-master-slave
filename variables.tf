variable "aws_region" {
  description = "The AWS region to create resources in"
  type        = string
  default     = "ap-south-1"
}

variable "tags" {
  description = "Tags to apply to all resources."
  type        = map(string)
}

variable "OU" {
  description = "Organizational Unit."
  type        = string
}

variable "BU" {
  description = "Business Unit."
  type        = string
}

variable "PU" {
  description = "Project Unit."
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g., uat, prod, dev)."
  type        = string
}

variable "project_name" {
  description = "Project Name"
  type        = string
}

# VPC configuration
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for VPC"
  type        = bool
  default     = true
}

variable "create_intra_subnets" {
  description = "Create intra subnets in the VPC"
  type        = bool
  default     = false
}

variable "create_database_subnets" {
  description = "Create database subnets in the VPC"
  type        = bool
  default     = false
}

variable "allowed_cidrs" {
  description = "List of CIDR blocks allowed to access Jenkins"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

# variable "whitelisted_ip_addresses" {
#   description = "List of whitelisted IP addresses in CIDR notation for allowing access to Jenkins"
#   type        = list(string)
# }

variable "certificate_arn" {
  description = "ARN of the SSL certificate for the load balancer"
  type        = string
  default     = null
}

variable "load_balancer_ssl_certificate_arn" {
  description = "ARN of the SSL certificate for the load balancer."
  type        = string
  default     = null
}

variable "enable_https" {
  description = "Set to true to enable HTTPS listener and HTTP to HTTPS redirection on ALB."
  type        = bool
  default     = true
}

variable "enable_http_https_redirection" {
  description = "Set to true to enable HTTP to HTTPS redirection on ALB. Requires enable_https to be true."
  type        = bool
  default     = false
}

# Jenkins configuration
variable "name_prefix" {
  description = "Prefix to use for resource naming"
  type        = string
  default     = "jenkins-bod"
}

variable "jenkins_port" {
  description = "Port for Jenkins web interface"
  type        = number
  default     = 8080
}

variable "jnlp_port" {
  description = "Port for Jenkins agent JNLP connections"
  type        = number
  default     = 50000
}

variable "jenkins_admin_username" {
  description = "Jenkins admin username"
  type        = string
  default     = "admin"
}

variable "jenkins_admin_password_ssm_parameter" {
  description = "SSM parameter name containing Jenkins admin password"
  type        = string
  default     = "/jenkins/admin/password"
}

variable "jenkins_admin_username_ssm_parameter" {
  description = "SSM parameter name containing Jenkins admin username"
  type        = string
  default     = "/jenkins/admin/username"
}

variable "jenkins_domain" {
  description = "Domain name for Jenkins"
  type        = string
  default     = ""
}



variable "health_check_path" {
  description = "Path for ALB health check"
  type        = string
  default     = "/login"
}

# Route 53 integration removed

variable "logs_retention_in_days" {
  description = "Number of days to retain logs in CloudWatch"
  type        = number
  default     = 30
}

# EFS configuration
variable "efs_performance_mode" {
  description = "Performance mode for the EFS file system"
  type        = string
  default     = "generalPurpose"
}

variable "efs_throughput_mode" {
  description = "Throughput mode for the EFS file system"
  type        = string
  default     = "bursting"
}

variable "enable_efs_backup" {
  description = "Whether to enable AWS Backup for EFS"
  type        = bool
  default     = true
}

variable "backup_retention_days" {
  description = "Number of days to retain backups"
  type        = number
  default     = 30
}

variable "backup_role_arn" {
  description = "ARN of the IAM role for AWS Backup"
  type        = string
  default     = null
}

# ALB configuration
variable "enable_deletion_protection" {
  description = "Enable deletion protection for ALB"
  type        = bool
  default     = true
}

variable "logs_bucket_name" {
  description = "Name of the S3 bucket for ALB access logs"
  type        = string
  default     = ""
}

# ECS configuration
variable "controller_cpu" {
  description = "CPU units for the Jenkins controller task"
  type        = number
  default     = 1024
}

variable "controller_memory" {
  description = "Memory for the Jenkins controller task (MB)"
  type        = number
  default     = 2048
}

variable "agent_cpu" {
  description = "CPU units for the Jenkins agent task"
  type        = number
  default     = 512
}

variable "agent_memory" {
  description = "Memory for the Jenkins agent task (MB)"
  type        = number
  default     = 1024
}

variable "jenkins_image" {
  description = "Jenkins Docker image to use"
  type        = string
  default     = "jenkins/jenkins:lts-jdk17"
}

variable "jenkins_agent_image" {
  description = "Jenkins Agent Docker image to use"
  type        = string
  default     = "jenkins/agent:latest"
}

variable "jenkins_agent_service_config" {
  description = "Configuration for the Jenkins agent ECS service (CPU and Memory)"
  type = object({
    cpu    = number
    memory = number
  })
  default = {
    cpu    = 256
    memory = 512
  }
}

variable "kms_key_arn" {
  description = "ARN of the CloudHSM AWS KMS key."
  type        = string
}

variable "kms_alias_arn" {
  description = "ARN of the CloudHSM AWS KMS key alias."
  type        = string
}

variable "ecs_cluster_fargate_capacity" {
  description = "Configuration for the ECS Fargate cluster capacity."
  type = object({
    FARGATE = object({
      default_capacity_provider_strategy = object({
        base   = number
        weight = number
      })
    })
    FARGATE_SPOT = object({
      default_capacity_provider_strategy = object({
        base   = number
        weight = number
      })
    })
  })
  default = {
    FARGATE = {
      default_capacity_provider_strategy = {
        base   = 1
        weight = 100
      }
    }
    FARGATE_SPOT = {
      default_capacity_provider_strategy = {
        base   = 0
        weight = 0
      }
    }
  }
}

# End of variables
