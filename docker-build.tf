
resource "null_resource" "docker_login" {
  triggers = {
    # A trigger is required, but we only need this to run once.
    # The region is unlikely to change, making it a stable trigger.
    aws_region = var.aws_region
  }

  provisioner "local-exec" {
    command = "aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com"
  }
}

# Build and push the Jenkins controller image
resource "null_resource" "build_and_push_controller" {
  depends_on = [aws_ecr_repository.jenkins_controller, null_resource.docker_login]

  triggers = {
    dockerfile_sha1 = filesha256("${path.module}/docker/controller/Dockerfile")
    # Create a single hash from all other files in the controller directory
    context_sha1 = sha1(join("", [for f in fileset("${path.module}/docker/controller", "**") : f != "Dockerfile" ? filebase64sha256("${path.module}/docker/controller/${f}") : ""]))
    # timestamp       = timestamp()
  }

  provisioner "local-exec" {
    command = <<EOT
      BUILD_TAG=$(date +%Y%m%d%H%M%S)
      docker build --no-cache --platform linux/amd64 -t ${aws_ecr_repository.jenkins_controller.repository_url}:"$BUILD_TAG" -t ${aws_ecr_repository.jenkins_controller.repository_url}:latest ${path.module}/docker/controller
      docker push ${aws_ecr_repository.jenkins_controller.repository_url}:"$BUILD_TAG"
      docker push ${aws_ecr_repository.jenkins_controller.repository_url}:latest
    EOT
  }
}

# Build and push the Jenkins agent image
resource "null_resource" "build_and_push_agent" {
  depends_on = [aws_ecr_repository.jenkins_agent, null_resource.docker_login]

  triggers = {
    dockerfile_sha1 = filesha256("${path.module}/docker/agent/Dockerfile")
    # Create a single hash from all other files in the agent directory
    context_sha1 = sha1(join("", [for f in fileset("${path.module}/docker/agent", "**") : f != "Dockerfile" ? filebase64sha256("${path.module}/docker/agent/${f}") : ""]))
    # timestamp       = timestamp()
  }

  provisioner "local-exec" {
    command = <<EOT
      BUILD_TAG=$(date +%Y%m%d%H%M%S)
      docker build --no-cache --platform linux/amd64 -t ${aws_ecr_repository.jenkins_agent.repository_url}:"$BUILD_TAG" -t ${aws_ecr_repository.jenkins_agent.repository_url}:latest ${path.module}/docker/agent
      docker push ${aws_ecr_repository.jenkins_agent.repository_url}:"$BUILD_TAG"
      docker push ${aws_ecr_repository.jenkins_agent.repository_url}:latest
    EOT
  }
}

