################################################################################
# Security Group for ALB
################################################################################

resource "aws_security_group" "alb" {
  name_prefix = "${var.name_prefix}-alb-"
  vpc_id      = var.vpc_id
  description = "Security group for Jenkins ALB"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidrs
    description = "Allow HTTP access from allowed CIDRs"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidrs
    description = "Allow HTTPS access from allowed CIDRs"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-alb-sg"
  })

  lifecycle {
    create_before_destroy = true
  }
}

################################################################################
# Security Group for Jenkins Controller
################################################################################

resource "aws_security_group" "jenkins_controller" {
  name_prefix = "${var.name_prefix}-controller-"
  vpc_id      = var.vpc_id
  description = "Security group for Jenkins controller"

  ingress {
    from_port       = var.jenkins_port
    to_port         = var.jenkins_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
    description     = "Allow access to Jenkins web UI from ALB"
  }

  ingress {
    from_port       = var.jnlp_port
    to_port         = var.jnlp_port
    protocol        = "tcp"
    security_groups = [aws_security_group.jenkins_agents.id]
    description     = "Allow JNLP access from Jenkins agents"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-controller-sg"
  })

  lifecycle {
    create_before_destroy = true
  }
}

################################################################################
# Security Group for Jenkins Agents
################################################################################

resource "aws_security_group" "jenkins_agents" {
  name_prefix = "${var.name_prefix}-agents-"
  vpc_id      = var.vpc_id
  description = "Security group for Jenkins agents"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-agents-sg"
  })

  lifecycle {
    create_before_destroy = true
  }
}

################################################################################
# Security Group for EFS
################################################################################

resource "aws_security_group" "efs" {
  name_prefix = "${var.name_prefix}-efs-"
  vpc_id      = var.vpc_id
  description = "Security group for Jenkins EFS"

  ingress {
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.jenkins_controller.id]
    description     = "Allow NFS access from Jenkins controller"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-efs-sg"
  })

  lifecycle {
    create_before_destroy = true
  }
}
