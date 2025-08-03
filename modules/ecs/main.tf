################################################################################
# ECS Cluster
################################################################################

resource "aws_ecs_cluster" "jenkins" {
  name = "${var.name_prefix}-cluster"

  configuration {
    execute_command_configuration {
      logging = "OVERRIDE"
      log_configuration {
        cloud_watch_log_group_name = aws_cloudwatch_log_group.ecs.name
      }
    }
  }

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = var.tags
}

resource "aws_ecs_cluster_capacity_providers" "jenkins" {
  cluster_name = aws_ecs_cluster.jenkins.name

  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}

################################################################################
# CloudWatch Log Group
################################################################################

resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/${var.name_prefix}-cluster"
  retention_in_days = var.logs_retention_in_days
  kms_key_id        = var.kms_key_arn

  tags = var.tags
}

################################################################################
# Jenkins Controller Task Definition
################################################################################

resource "aws_ecs_task_definition" "jenkins_controller" {
  family                   = "${var.name_prefix}-controller"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.controller_cpu
  memory                   = var.controller_memory
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([
    {
      name      = "${var.name_prefix}-controller"
      image     = var.controller_image
      essential = true,
      command   = ["/bin/sh", "-c", "mkdir -p /var/jenkins_home/casc_configs && /usr/local/bin/jenkins.sh"]

      portMappings = [
        {
          containerPort = var.jenkins_port
          hostPort      = var.jenkins_port
          protocol      = "tcp"
        },
        {
          containerPort = var.jnlp_port
          hostPort      = var.jnlp_port
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "CASC_JENKINS_CONFIG",
          value = "/var/jenkins_home/casc_configs"
        },
        {
          name  = "ECS_CLUSTER_NAME"
          value = aws_ecs_cluster.jenkins.name
        },
        {
          name  = "AWS_REGION"
          value = var.region
        },
        {
          name  = "JENKINS_URL"
          value = var.jenkins_url
        },
        {
          name  = "JENKINS_TUNNEL"
          value = "${aws_service_discovery_service.jenkins_controller_sd[0].name}.${aws_service_discovery_private_dns_namespace.jenkins[0].name}:${var.jnlp_port}"
        },
        {
          name  = "AGENT_CPU"
          value = tostring(var.agent_cpu)
        },
        {
          name  = "AGENT_MEMORY"
          value = tostring(var.agent_memory)
        },
        {
          name  = "JENKINS_AGENT_IMAGE"
          value = var.agent_image
        },
        {
          name  = "AGENT_EXECUTION_ROLE_ARN"
          value = var.execution_role_arn
        },
        {
          name  = "AGENT_TASK_ROLE_ARN"
          value = var.agent_task_role_arn
        },
        {
          name  = "PRIVATE_SUBNETS"
          value = join(",", var.private_subnets)
        },
        {
          name  = "AGENT_SECURITY_GROUPS"
          value = var.agent_security_group_id
        },
        {
          name  = "AGENT_LOG_GROUP"
          value = aws_cloudwatch_log_group.agent.name
        }
      ]

      secrets = [
        {
          name      = "JENKINS_ADMIN_USER"
          valueFrom = var.jenkins_admin_username_arn
        },
        {
          name      = "JENKINS_ADMIN_PASSWORD"
          valueFrom = var.jenkins_admin_password_arn
        }
      ]

      mountPoints = [
        {
          sourceVolume  = "jenkins-home"
          containerPath = "/var/jenkins_home"
          readOnly      = false
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.controller.name
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = "controller"
        }
      }
    }
  ])

  volume {
    name = "jenkins-home"

    efs_volume_configuration {
      file_system_id     = var.efs_file_system_id
      transit_encryption = "ENABLED"

      authorization_config {
        access_point_id = var.efs_access_point_id
      }
    }
  }

  tags = var.tags
}

################################################################################
# CloudWatch Log Groups
################################################################################

resource "aws_cloudwatch_log_group" "controller" {
  name              = "/ecs/${var.name_prefix}-controller"
  retention_in_days = var.logs_retention_in_days
  kms_key_id        = var.kms_key_arn

  tags = var.tags
}

resource "aws_cloudwatch_log_group" "agent" {
  name              = "/ecs/${var.name_prefix}-agent"
  retention_in_days = var.logs_retention_in_days
  kms_key_id        = var.kms_key_arn

  tags = var.tags
}

################################################################################
# Jenkins Controller Service
################################################################################

resource "aws_service_discovery_private_dns_namespace" "jenkins" {
  count = var.enable_service_discovery ? 1 : 0

  name        = "jenkins.local"
  description = "Private DNS namespace for Jenkins services"
  vpc         = var.vpc_id
}

resource "aws_service_discovery_service" "jenkins_controller_sd" {
  count = var.enable_service_discovery ? 1 : 0

  name         = "jenkins-controller-sd"
  namespace_id = aws_service_discovery_private_dns_namespace.jenkins[0].id

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.jenkins[0].id
    dns_records {
      ttl  = 10
      type = "A"
    }
    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}


resource "aws_ecs_service" "jenkins_controller" {
  name                               = "${var.name_prefix}-controller"
  cluster                            = aws_ecs_cluster.jenkins.id
  task_definition                    = aws_ecs_task_definition.jenkins_controller.arn
  desired_count                      = 1
  launch_type                        = "FARGATE"
  platform_version                   = "LATEST"
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100
  health_check_grace_period_seconds  = 60

  dynamic "service_registries" {
    for_each = var.enable_service_discovery ? [1] : []
    content {
      registry_arn = aws_service_discovery_service.jenkins_controller_sd[0].arn
    }
  }

  network_configuration {
    subnets          = var.private_subnets
    security_groups  = [var.controller_security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "${var.name_prefix}-controller"
    container_port   = var.jenkins_port
  }

  # Prevent replacement when task definition changes
  lifecycle {
    ignore_changes = [
      desired_count
    ]
  }

  tags = var.tags
}
