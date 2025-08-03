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

variable "allowed_cidrs" {
  description = "List of CIDR blocks allowed to access Jenkins"
  type        = list(string)
  default     = ["0.0.0.0/0"]
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
