output "environment" {
  description = "The environment name."
  value       = var.environment
}

output "prefect_workspace_url" {
  description = "Check out your new workspace by clicking here."
  value       = "https://app.prefect.cloud/account/${var.prefect_account_id}/workspace/${prefect_workspace.workspace.id}/"
}

output "aws_ecr_repository" {
  description = "The AWS ECR repository base URL (for ECR login)."
  value       = data.aws_ecr_authorization_token.token.proxy_endpoint
}

output "aws_region" {
  description = "The AWS region (for ECR login)."
  value       = var.aws_region
}
