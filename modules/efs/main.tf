################################################################################
# EFS File System
################################################################################

resource "aws_efs_file_system" "jenkins" {
  creation_token = "${var.name_prefix}-efs"
  
  performance_mode = var.efs_performance_mode
  throughput_mode  = var.efs_throughput_mode
  encrypted        = true
  kms_key_id       = var.kms_key_arn

  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-efs"
  })
}

resource "aws_efs_mount_target" "jenkins" {
  count          = length(var.private_subnet_ids)
  file_system_id = aws_efs_file_system.jenkins.id
  subnet_id      = var.private_subnet_ids[count.index]
  security_groups = [var.efs_security_group_id]
}

resource "aws_efs_access_point" "jenkins" {
  file_system_id = aws_efs_file_system.jenkins.id

  posix_user {
    gid = 1000
    uid = 1000
  }

  root_directory {
    path = "/jenkins_home"
    creation_info {
      owner_gid   = 1000
      owner_uid   = 1000
      permissions = "755"
    }
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-access-point"
  })
}

################################################################################
# EFS Backup (Optional)
################################################################################

resource "aws_backup_plan" "jenkins" {
  count = var.enable_efs_backup ? 1 : 0
  
  name = "${var.name_prefix}-efs-backup-plan"

  rule {
    rule_name         = "daily-backup"
    target_vault_name = aws_backup_vault.jenkins[0].name
    schedule          = "cron(0 1 * * ? *)" # Run at 1 AM UTC every day

    lifecycle {
      delete_after = var.backup_retention_days
    }
  }

  tags = var.tags
}

resource "aws_backup_vault" "jenkins" {
  count = var.enable_efs_backup ? 1 : 0
  
  name        = "${var.name_prefix}-backup-vault"
  kms_key_arn = var.kms_key_arn
  
  tags = var.tags
}

resource "aws_backup_selection" "jenkins" {
  count = var.enable_efs_backup ? 1 : 0
  
  name         = "${var.name_prefix}-efs-backup-selection"
  iam_role_arn = var.backup_role_arn
  plan_id      = aws_backup_plan.jenkins[0].id

  resources = [
    aws_efs_file_system.jenkins.arn
  ]
}
