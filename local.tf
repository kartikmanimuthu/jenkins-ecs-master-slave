##############################################################################
# Local Variables
##############################################################################

##############################################################################
# Core and Metadata Variables
##############################################################################
locals {
  environment  = var.environment
  project_name = var.project_name

  # Standard organizational tagging strategy
  tags = merge(var.tags,
    {
      Terraform    = "true"
      OU           = var.OU
      BU           = var.BU
      PU           = var.PU
      project_name = local.project_name
      environment  = local.environment
    }
  )
}

##############################################################################
# Security Configuration
##############################################################################
locals {
  # Default CIDR for public access
  default_public_cidr = "0.0.0.0/0"

  # HTTP access rules
  http_ingress_rules = {
    "http_from_anywhere" = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      description = "HTTP from anywhere"
      cidr_ipv4   = local.default_public_cidr
    }
  }

  # HTTPS access rules
  https_ingress_rules = {
    "https_from_anywhere" = {
      from_port   = 443
      to_port     = 443
      ip_protocol = "tcp"
      description = "HTTPS from anywhere"
      cidr_ipv4   = local.default_public_cidr
    }
  }

  # ICMP access rule - Based on best practices from memory 5b41245b
  icmp_ingress_rules = {
    "icmp_from_internal" = {
      from_port   = -1
      to_port     = -1
      ip_protocol = "icmp"
      description = "ICMP from internal networks"
      cidr_ipv4   = "10.0.0.0/8"
    }
  }
}

##############################################################################
# Infrastructure Configuration
##############################################################################
locals {
  # SSL/TLS and Encryption
  load_balancer_ssl_certificate_arn = var.load_balancer_ssl_certificate_arn
  aws_kms_key_arn                   = var.kms_key_arn
  aws_kms_alias_arn                 = var.kms_alias_arn

  # Monitoring and Logging
  logs_retention_in_days = var.logs_retention_in_days

  # Capacity Management
  ecs_cluster_fargate_capacity = var.ecs_cluster_fargate_capacity
}

##############################################################################
# Jenkins Service Configuration
##############################################################################
locals {
  jenkins_service = {
    name              = "${local.project_name}-jenkins"
    port              = 8080
    agents_port       = 50000
    alb_path          = ["/*"]
    health_check_path = "/jenkins"
    alb_priority      = 1 # Explicit priority setting based on centralized approach

    config = {
      cpu    = 4096
      memory = 8192
    }
  }
}

locals {
  # Common naming convention
  name_prefix = var.name_prefix

  # AWS region and account ID
  region = var.aws_region
}
