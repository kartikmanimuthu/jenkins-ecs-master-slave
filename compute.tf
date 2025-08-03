################################################################################
# Data Sources for Existing Resources
################################################################################

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}


# Generate a random password for the Jenkins admin user
resource "random_password" "jenkins_admin_password" {
  length           = 16
  special          = true
  override_special = "!#$%&'()*+,-./:;<=>?@[]^_`{|}~"
}

resource "aws_iam_policy" "ssm_jenkins_access" {
  name        = "${var.project_name}-ssm-jenkins-access-${random_id.id.hex}"
  description = "Allow access to the Jenkins admin credentials in SSM"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ssm:GetParameters"
        ]
        Effect = "Allow"
        Resource = [
          aws_ssm_parameter.jenkins_admin_password.arn,
          aws_ssm_parameter.jenkins_admin_username.arn
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_ssm_access" {
  role       = "${var.name_prefix}-task-execution-role"
  policy_arn = aws_iam_policy.ssm_jenkins_access.arn
}

resource "random_id" "id" {
  byte_length = 2
}

# Store the generated password in AWS SSM Parameter Store
resource "aws_ssm_parameter" "jenkins_admin_password" {
  name        = var.jenkins_admin_password_ssm_parameter
  description = "Generated password for Jenkins admin user"
  type        = "SecureString"
  value       = random_password.jenkins_admin_password.result

  tags = merge(
    var.tags,
    {
      Name = "jenkins-admin-password"
    }
  )
}

# Store the Jenkins admin username in AWS SSM Parameter Store
resource "aws_ssm_parameter" "jenkins_admin_username" {
  name        = var.jenkins_admin_username_ssm_parameter
  description = "Jenkins admin username"
  type        = "String"
  value       = var.jenkins_admin_username
  overwrite   = true

  tags = merge(
    var.tags,
    {
      Name = "jenkins-admin-username"
    }
  )
}




# Security Group for the SSM VPC Endpoint
resource "aws_security_group" "ssm_vpc_endpoint_sg" {
  name        = "${var.project_name}-ssm-vpc-endpoint-sg"
  description = "Allow TLS from the ECS tasks to the SSM VPC Endpoint"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description     = "TLS from ECS Controller to SSM Endpoint"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [module.security_groups.controller_security_group_id]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-ssm-vpc-endpoint-sg"
    }
  )
}

# VPC Endpoint for SSM to allow ECS tasks to pull secrets
resource "aws_vpc_endpoint" "ssm" {
  vpc_id              = module.vpc.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.ssm"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  subnet_ids = module.vpc.private_subnets
  security_group_ids = [
    aws_security_group.ssm_vpc_endpoint_sg.id
  ]

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-ssm-endpoint"
    }
  )
}



################################################################################
# ECR Repositories for Jenkins Controller and Agent
################################################################################

resource "aws_ecr_repository" "jenkins_controller" {
  name                 = "${var.name_prefix}-controller"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = var.kms_key_arn
  }

  tags = local.tags
}

resource "aws_ecr_repository" "jenkins_agent" {
  name                 = "${var.name_prefix}-agent"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = var.kms_key_arn
  }

  tags = local.tags
}


################################################################################
# IAM Roles
################################################################################

# ECS task execution role
resource "aws_iam_role" "ecs_task_execution" {
  name = "${var.name_prefix}-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Controller task role
resource "aws_iam_role" "jenkins_controller_task" {
  name = "${var.name_prefix}-controller-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "jenkins_controller_task_ssm_access" {
  role       = aws_iam_role.jenkins_controller_task.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
}

resource "aws_iam_role_policy" "jenkins_controller_ecs_access" {
  name = "${var.name_prefix}-controller-ecs-access-policy"
  role = aws_iam_role.jenkins_controller_task.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecs:DescribeTaskDefinition",
          "ecs:RegisterTaskDefinition",
          "ecs:DeregisterTaskDefinition",
          "ecs:ListTaskDefinitions",
          "ecs:ListClusters",
          "ecs:DescribeContainerInstances",
          "ecs:RunTask",
          "ecs:StopTask",
          "ecs:DescribeTasks",
          "ecs:TagResource",
          "ecs:ListTagsForResource"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "iam:PassRole"
        ]
        Resource = [
          aws_iam_role.ecs_task_execution.arn,
          aws_iam_role.jenkins_agent_task.arn
        ]
      }
    ]
  })
}

resource "aws_iam_role" "jenkins_agent_task" {
  name = "${var.name_prefix}-jenkins-agent-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = local.tags
}

resource "aws_iam_role_policy" "jenkins_agent_efs_access" {
  name = "${var.name_prefix}-jenkins-agent-efs-access-policy"
  role = aws_iam_role.jenkins_agent_task.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "elasticfilesystem:ClientMount",
          "elasticfilesystem:ClientWrite"
        ]
        Resource = module.efs.efs_file_system_arn
      }
    ]
  })
}

resource "aws_iam_role_policy" "jenkins_agent_ecs_access" {
  name = "${var.name_prefix}-jenkins-agent-ecs-access-policy"
  role = aws_iam_role.jenkins_agent_task.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecs:RegisterTaskDefinition",
          "ecs:ListClusters",
          "ecs:DescribeContainerInstances",
          "ecs:ListTaskDefinitions",
          "ecs:DescribeTaskDefinition",
          "ecs:DeregisterTaskDefinition",
          "ecs:ListTagsForResource"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecs:ListContainerInstances"
        ]
        Resource = "arn:aws:ecs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:cluster/${module.ecs.cluster_id}"
      },
      {
        Effect = "Allow"
        Action = [
          "ecs:RunTask"
        ]
        Resource = "arn:aws:ecs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:task-definition/*"
        Condition = {
          ArnEquals = {
            "ecs:cluster" = "arn:aws:ecs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:cluster/${module.ecs.cluster_id}"
          }
        }
      },
      {
        Effect = "Allow"
        Action = [
          "ecs:StopTask"
        ]
        Resource = "arn:aws:ecs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:task/*"
        Condition = {
          ArnEquals = {
            "ecs:cluster" = "arn:aws:ecs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:cluster/${module.ecs.cluster_id}"
          }
        }
      },
      {
        Effect = "Allow"
        Action = [
          "ecs:DescribeTasks"
        ]
        Resource = "arn:aws:ecs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:task/*"
        Condition = {
          ArnEquals = {
            "ecs:cluster" = "arn:aws:ecs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:cluster/${module.ecs.cluster_id}"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "jenkins_agent_pass_role" {
  name = "${var.name_prefix}-jenkins-agent-pass-role-policy"
  role = aws_iam_role.jenkins_agent_task.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "iam:GetRole",
          "iam:PassRole"
        ]
        Resource = aws_iam_role.ecs_task_execution.arn
      }
    ]
  })
}

################################################################################
# Security Groups
################################################################################


module "security_groups" {
  source = "./modules/security-groups"

  name_prefix   = var.name_prefix
  vpc_id        = module.vpc.vpc_id
  allowed_cidrs = var.allowed_cidrs
  jenkins_port  = var.jenkins_port
  jnlp_port     = var.jnlp_port

  tags = local.tags
}



################################################################################
# EFS File System
################################################################################

module "efs" {
  source = "./modules/efs"

  name_prefix           = var.name_prefix
  private_subnet_ids    = module.vpc.private_subnets
  efs_security_group_id = module.security_groups.efs_security_group_id
  kms_key_arn           = var.kms_key_arn

  efs_performance_mode = var.efs_performance_mode
  efs_throughput_mode  = var.efs_throughput_mode
  enable_efs_backup    = var.enable_efs_backup
  backup_role_arn      = var.backup_role_arn

  tags = local.tags
}

################################################################################
# ALB
################################################################################

module "alb" {
  source = "./modules/alb"

  name_prefix                = var.name_prefix
  vpc_id                     = module.vpc.vpc_id
  public_subnet_ids          = module.vpc.public_subnets
  alb_security_group_id      = module.security_groups.alb_security_group_id
  target_port                = var.jenkins_port
  logs_bucket_name           = ""
  enable_deletion_protection = var.enable_deletion_protection
  certificate_arn            = var.load_balancer_ssl_certificate_arn
  enable_https               = var.enable_https
  enable_http_https_redirection = var.enable_http_https_redirection
  tags                       = local.tags
}

################################################################################
# ECS Cluster and Services
################################################################################

module "ecs" {
  source = "./modules/ecs"

  name_prefix = var.name_prefix
  region      = var.aws_region
  kms_key_arn = var.kms_key_arn

  controller_image = "${aws_ecr_repository.jenkins_controller.repository_url}:latest"
  agent_image      = "${aws_ecr_repository.jenkins_agent.repository_url}:latest"

  controller_cpu    = var.controller_cpu
  controller_memory = var.controller_memory
  agent_cpu         = var.agent_cpu
  agent_memory      = var.agent_memory

  execution_role_arn  = aws_iam_role.ecs_task_execution.arn
  task_role_arn       = aws_iam_role.jenkins_controller_task.arn
  agent_task_role_arn = aws_iam_role.jenkins_agent_task.arn

  jenkins_port = var.jenkins_port
  jnlp_port    = var.jnlp_port

  private_subnets              = module.vpc.private_subnets
  controller_security_group_id = module.security_groups.controller_security_group_id
  agent_security_group_id      = module.security_groups.agents_security_group_id

  target_group_arn = module.alb.target_group_arn

  efs_file_system_id  = module.efs.efs_file_system_id
  efs_access_point_id = module.efs.efs_access_point_id

  jenkins_admin_username     = var.jenkins_admin_username
  jenkins_admin_password_arn = aws_ssm_parameter.jenkins_admin_password.arn
  jenkins_admin_username_arn = aws_ssm_parameter.jenkins_admin_username.arn

  enable_service_discovery = true

  jenkins_url = var.jenkins_domain != "" ? "https://${var.jenkins_domain}" : "http://${module.alb.alb_dns_name}"

  logs_retention_in_days = var.logs_retention_in_days

  vpc_id = module.vpc.vpc_id

  tags = local.tags
}
