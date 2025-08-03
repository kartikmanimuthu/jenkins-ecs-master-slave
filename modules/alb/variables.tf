variable "name_prefix" {
  description = "Prefix to use for resource naming"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for ALB"
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "ID of the security group for ALB"
  type        = string
}

variable "target_port" {
  description = "Port on the target to route traffic to"
  type        = number
  default     = 8080
}

variable "health_check_path" {
  description = "Path for health check"
  type        = string
  default     = "/login"
}

variable "certificate_arn" {
  description = "ARN of the SSL certificate for HTTPS"
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
