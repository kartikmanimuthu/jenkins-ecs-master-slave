output "alb_security_group_id" {
  description = "ID of the ALB security group"
  value       = aws_security_group.alb.id
}

output "controller_security_group_id" {
  description = "ID of the Jenkins controller security group"
  value       = aws_security_group.jenkins_controller.id
}

output "agents_security_group_id" {
  description = "ID of the Jenkins agents security group"
  value       = aws_security_group.jenkins_agents.id
}

output "efs_security_group_id" {
  description = "ID of the EFS security group"
  value       = aws_security_group.efs.id
}
