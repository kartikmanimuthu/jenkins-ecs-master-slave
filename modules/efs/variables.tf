variable "name_prefix" {
  description = "Prefix to use for resource naming"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for EFS mount targets"
  type        = list(string)
}

variable "efs_security_group_id" {
  description = "ID of the security group for EFS"
  type        = string
}

variable "kms_key_arn" {
  description = "ARN of KMS key for encryption"
  type        = string
}

variable "efs_performance_mode" {
  description = "Performance mode for the EFS file system"
  type        = string
  default     = "generalPurpose"
  
  validation {
    condition     = contains(["generalPurpose", "maxIO"], var.efs_performance_mode)
    error_message = "Valid values for efs_performance_mode are 'generalPurpose' or 'maxIO'."
  }
}

variable "efs_throughput_mode" {
  description = "Throughput mode for the EFS file system"
  type        = string
  default     = "bursting"
  
  validation {
    condition     = contains(["bursting", "provisioned", "elastic"], var.efs_throughput_mode)
    error_message = "Valid values for efs_throughput_mode are 'bursting', 'provisioned', or 'elastic'."
  }
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
