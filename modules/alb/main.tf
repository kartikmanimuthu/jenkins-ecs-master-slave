################################################################################
# Application Load Balancer
################################################################################

resource "aws_lb" "jenkins" {
  name                       = "${var.name_prefix}-alb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [var.alb_security_group_id]
  subnets                    = var.public_subnet_ids
  enable_deletion_protection = var.enable_deletion_protection
  idle_timeout               = 60

  access_logs {
    bucket  = var.logs_bucket_name
    prefix  = "alb-logs"
    enabled = var.logs_bucket_name != "" ? true : false
  }

  tags = var.tags
}

resource "aws_lb_target_group" "jenkins" {
  name                 = "${var.name_prefix}-tg"
  port                 = var.target_port
  protocol             = "HTTP"
  vpc_id               = var.vpc_id
  target_type          = "ip"
  deregistration_delay = 60

  health_check {
    enabled             = true
    interval            = 30
    path                = var.health_check_path
    port                = "traffic-port"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    protocol            = "HTTP"
    matcher             = "200,301,302,303"
  }

  tags = var.tags
}

# HTTP listener - forwards traffic when HTTPS is disabled, redirects to HTTPS when enabled
resource "aws_lb_listener" "http" {
  count = !var.enable_http_https_redirection ? 1 : 0

  load_balancer_arn = aws_lb.jenkins.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.jenkins.arn
  }

  tags = var.tags
}

# HTTP listener with redirect to HTTPS - only active when HTTPS is enabled
resource "aws_lb_listener" "http_redirect" {
  count = var.enable_https && var.enable_http_https_redirection ? 1 : 0

  load_balancer_arn = aws_lb.jenkins.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  tags = var.tags
}

# HTTPS listener - only active when HTTPS is enabled
resource "aws_lb_listener" "https" {
  count = var.enable_https ? 1 : 0

  load_balancer_arn = aws_lb.jenkins.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-Res-2021-06"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.jenkins.arn
  }

  tags = var.tags
}
