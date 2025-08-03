output "cluster_id" {
  description = "ID of the ECS cluster"
  value       = aws_ecs_cluster.jenkins.id
}

output "cluster_arn" {
  description = "ARN of the ECS cluster"
  value       = aws_ecs_cluster.jenkins.arn
}

output "controller_task_definition_arn" {
  description = "ARN of the Jenkins controller task definition"
  value       = aws_ecs_task_definition.jenkins_controller.arn
}

output "controller_service_id" {
  description = "ID of the Jenkins controller ECS service"
  value       = aws_ecs_service.jenkins_controller.id
}

output "controller_log_group_name" {
  description = "Name of the CloudWatch log group for the Jenkins controller"
  value       = aws_cloudwatch_log_group.controller.name
}

output "agent_log_group_name" {
  description = "Name of the CloudWatch log group for the Jenkins agents"
  value       = aws_cloudwatch_log_group.agent.name
}

output "cluster_log_group_name" {
  description = "Name of the CloudWatch log group for the ECS cluster"
  value       = aws_cloudwatch_log_group.ecs.name
}
