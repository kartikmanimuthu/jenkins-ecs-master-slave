variable "name_prefix" {
  description = "Prefix to use for resource naming"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "kms_key_arn" {
  description = "ARN of the KMS key for encryption"
  type        = string
}

variable "logs_retention_in_days" {
  description = "CloudWatch logs retention in days"
  type        = number
  default     = 30
}

variable "controller_image" {
  description = "Docker image for Jenkins controller"
  type        = string
}

variable "agent_image" {
  description = "Docker image for Jenkins agent"
  type        = string
}

variable "controller_cpu" {
  description = "CPU units for Jenkins controller"
  type        = number
  default     = 1024
}

variable "controller_memory" {
  description = "Memory for Jenkins controller in MB"
  type        = number
  default     = 2048
}

variable "agent_cpu" {
  description = "CPU units for Jenkins agent"
  type        = number
  default     = 1024
}

variable "agent_memory" {
  description = "Memory for Jenkins agent in MB"
  type        = number
  default     = 2048
}

variable "execution_role_arn" {
  description = "ARN of the task execution role"
  type        = string
}

variable "task_role_arn" {
  description = "ARN of the task role for controller"
  type        = string
}

variable "agent_task_role_arn" {
  description = "ARN of the task role for agent"
  type        = string
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

variable "private_subnets" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "controller_security_group_id" {
  description = "Security group ID for Jenkins controller"
  type        = string
}

variable "agent_security_group_id" {
  description = "Security group ID for Jenkins agents"
}

variable "enable_service_discovery" {
  description = "Enable service discovery for the Jenkins controller"
  type        = bool
  default     = false
}

variable "service_discovery_namespace_id" {
  description = "The ID of the service discovery namespace"
  type        = string
  default     = ""
}

variable "controller_service_name" {
  description = "The name of the controller service for service discovery"
  type        = string
  default     = "jenkins-master"
}

variable "target_group_arn" {
  description = "ARN of ALB target group"
  type        = string
}

variable "efs_file_system_id" {
  description = "ID of the EFS file system"
  type        = string
}

variable "efs_access_point_id" {
  description = "ID of the EFS access point"
  type        = string
}

variable "jenkins_admin_username" {
  description = "Jenkins admin username"
  type        = string
  default     = "admin"
}

variable "jenkins_admin_password_arn" {
  description = "ARN of the parameter store parameter containing Jenkins admin password"
  type        = string
}

variable "jenkins_admin_username_arn" {
  description = "ARN of the parameter store parameter containing Jenkins admin username"
  type        = string
}

variable "jenkins_url" {
  description = "Jenkins URL for agents to connect to"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where the ECS cluster is deployed"
  type        = string
}
