output "efs_file_system_id" {
  description = "ID of the EFS file system"
  value       = aws_efs_file_system.jenkins.id
}

output "efs_file_system_arn" {
  description = "ARN of the EFS file system"
  value       = aws_efs_file_system.jenkins.arn
}

output "efs_access_point_id" {
  description = "ID of the EFS access point"
  value       = aws_efs_access_point.jenkins.id
}

output "efs_dns_name" {
  description = "DNS name of the EFS file system"
  value       = aws_efs_file_system.jenkins.dns_name
}
