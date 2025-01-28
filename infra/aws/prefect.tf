// Create a workspace
resource "prefect_workspace" "workspace" {
  name   = var.environment
  handle = var.environment
}

// Create a service account and add it to the workspace
resource "prefect_service_account" "service_account" {
  name              = "prefect-worker-${var.environment}"
  account_role_name = "Member"
}

data "prefect_workspace_role" "worker" {
  name = "Worker"
}

resource "prefect_workspace_access" "workspace_access" {
  accessor_type     = "SERVICE_ACCOUNT"
  accessor_id       = prefect_service_account.service_account.id
  workspace_id      = prefect_workspace.workspace.id
  workspace_role_id = data.prefect_workspace_role.worker.id
}

// Store the flow repository URL, bucket name, and environment in variables for later use
resource "prefect_variable" "flow_image" {
  name         = "flow_image"
  value        = aws_ecr_repository.prefect_flow_image.repository_url
  workspace_id = prefect_workspace.workspace.id
}

resource "prefect_variable" "storage_bucket" {
  name         = "storage_bucket"
  value        = "s3://${aws_s3_bucket.prefect_storage.bucket}"
  workspace_id = prefect_workspace.workspace.id
}

resource "prefect_variable" "environment" {
  name         = "environment"
  value        = var.environment
  workspace_id = prefect_workspace.workspace.id
}

// Configure an ECS work pool
data "prefect_worker_metadata" "d" {
  workspace_id = prefect_workspace.workspace.id
}

resource "prefect_work_pool" "ecs_work_pool" {
  name         = "ecs"
  type         = "ecs"
  paused       = false
  workspace_id = prefect_workspace.workspace.id

  // Merge the default cloud run base job template with custom variables
  base_job_template = jsonencode(merge(
    jsondecode(data.prefect_worker_metadata.d.base_job_configs.ecs),
    {
      variables = merge(
        jsondecode(data.prefect_worker_metadata.d.base_job_configs.ecs).variables,
        {
          properties = merge(
            jsondecode(data.prefect_worker_metadata.d.base_job_configs.ecs).variables.properties,
            {
              // Anything in variables can be set here
              for key, value in {
                cluster                   = aws_ecs_cluster.prefect_worker_cluster.name,
                launch_type               = "FARGATE",
                cpu                       = var.flow_run_cpu,
                memory                    = var.flow_run_memory,
                task_role_arn             = aws_iam_role.prefect_flow_task_role.arn,
                execution_role_arn        = aws_iam_role.prefect_flow_execution_role.arn,
                vpc_id                    = var.aws_vpc_id,
                configure_cloudwatch_logs = true,
                network_configuration = {
                  assignPublicIp = "ENABLED",
                  subnets        = var.aws_subnet_ids,
                  securityGroups = [aws_security_group.prefect_sg.id]
                }
                task_watch_poll_interval        = 30,
                match_latest_revision_in_family = true,
                } : key => merge(
                jsondecode(data.prefect_worker_metadata.d.base_job_configs.ecs).variables.properties[key],
                { default = value }
              )
            }
          )
        }
      )
    }
  ))
}