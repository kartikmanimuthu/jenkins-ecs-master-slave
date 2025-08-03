##############################################################################
# VPC Outputs
##############################################################################

output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnets
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnets
}

##############################################################################
# Jenkins Outputs
##############################################################################

output "jenkins_url" {
  description = "URL of the Jenkins server"
  value       = var.jenkins_domain != "" ? "https://${var.jenkins_domain}" : "https://${module.alb.alb_dns_name}"
}

output "jenkins_login_information" {
  description = "Information for accessing the Jenkins dashboard"
  value = {
    url      = var.jenkins_domain != "" ? "https://${var.jenkins_domain}" : "https://${module.alb.alb_dns_name}"
    username = "See SSM parameter: ${var.jenkins_admin_username_ssm_parameter}"
    password = "See SSM parameter: ${var.jenkins_admin_password_ssm_parameter}"
  }
}

output "jenkins_cluster_id" {
  description = "ID of the ECS cluster hosting Jenkins"
  value       = module.ecs.cluster_id
}

output "jenkins_controller_task_definition_arn" {
  description = "ARN of the Jenkins controller ECS task definition"
  value       = module.ecs.controller_task_definition_arn
}

output "jenkins_controller_service_id" {
  description = "ID of the Jenkins controller ECS service"
  value       = module.ecs.controller_service_id
}

output "jenkins_controller_log_group_name" {
  description = "Name of the CloudWatch log group for the Jenkins controller"
  value       = module.ecs.controller_log_group_name
}

output "jenkins_agent_log_group_name" {
  description = "Name of the CloudWatch log group for the Jenkins agents"
  value       = module.ecs.agent_log_group_name
}

output "jenkins_cluster_log_group_name" {
  description = "Name of the CloudWatch log group for the ECS cluster"
  value       = module.ecs.cluster_log_group_name
}

output "alb_id" {
  description = "ID of the Application Load Balancer"
  value       = module.alb.alb_id
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = module.alb.alb_arn
}

output "alb_security_group_id" {
  description = "ID of the security group for ALB"
  value       = module.security_groups.alb_security_group_id
}

output "efs_security_group_id" {
  description = "ID of the security group for EFS"
  value       = module.security_groups.efs_security_group_id
}

output "efs_file_system_id" {
  description = "ID of the EFS file system used for Jenkins data"
  value       = module.efs.efs_file_system_id
}

output "efs_access_point_id" {
  description = "ID of the EFS access point"
  value       = module.efs.efs_access_point_id
}

output "controller_security_group_id" {
  description = "ID of the security group for Jenkins controller"
  value       = module.security_groups.controller_security_group_id
}

output "agents_security_group_id" {
  description = "ID of the security group for Jenkins agents"
  value       = module.security_groups.agents_security_group_id
}


