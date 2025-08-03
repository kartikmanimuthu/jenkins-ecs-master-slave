output "alb_id" {
  description = "ID of the Application Load Balancer"
  value       = aws_lb.jenkins.id
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.jenkins.arn
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.jenkins.dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the Application Load Balancer"
  value       = aws_lb.jenkins.zone_id
}

output "target_group_arn" {
  description = "ARN of the Target Group"
  value       = aws_lb_target_group.jenkins.arn
}

output "https_listener_arn" {
  description = "ARN of the HTTPS listener"
  value       = var.enable_https ? aws_lb_listener.https[0].arn : null
}

output "http_listener_arn" {
  description = "ARN of the HTTP listener (either plain HTTP or HTTP redirect)"
  value       = var.enable_https && var.enable_http_https_redirection ? aws_lb_listener.http_redirect[0].arn : aws_lb_listener.http[0].arn
}
