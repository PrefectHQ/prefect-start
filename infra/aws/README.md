# AWS Infrastructure

This directory contains all the Terraform code you need to get started with Prefect on AWS.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |
| <a name="requirement_docker"></a> [docker](#requirement\_docker) | ~> 3.0 |
| <a name="requirement_prefect"></a> [prefect](#requirement\_prefect) | ~> 2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |
| <a name="provider_docker"></a> [docker](#provider\_docker) | ~> 3.0 |
| <a name="provider_prefect"></a> [prefect](#provider\_prefect) | ~> 2.0 |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.prefect_worker_log_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_ecr_repository.prefect_flow_image](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |
| [aws_ecr_repository.prefect_worker_image](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |
| [aws_ecs_cluster.prefect_worker_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster) | resource |
| [aws_ecs_cluster_capacity_providers.prefect_worker_cluster_capacity_providers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster_capacity_providers) | resource |
| [aws_ecs_service.prefect_worker_service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.prefect_worker_task_definition](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_iam_role.prefect_flow_execution_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.prefect_flow_task_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.prefect_worker_execution_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.prefect_worker_task_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.prefect_flow_execution_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.prefect_flow_task_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.prefect_worker_execution_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.prefect_worker_task_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_s3_bucket.prefect_storage](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_notification.bucket_notification](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_notification) | resource |
| [aws_secretsmanager_secret.prefect_api_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_version.prefect_api_key_version](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_security_group.prefect_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.http_outbound](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.https_outbound](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [docker_image.prefect_worker_image](https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs/resources/image) | resource |
| [docker_registry_image.prefect_worker_image](https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs/resources/registry_image) | resource |
| [prefect_service_account.service_account](https://registry.terraform.io/providers/prefecthq/prefect/latest/docs/resources/service_account) | resource |
| [prefect_variable.environment](https://registry.terraform.io/providers/prefecthq/prefect/latest/docs/resources/variable) | resource |
| [prefect_variable.flow_image](https://registry.terraform.io/providers/prefecthq/prefect/latest/docs/resources/variable) | resource |
| [prefect_variable.storage_bucket](https://registry.terraform.io/providers/prefecthq/prefect/latest/docs/resources/variable) | resource |
| [prefect_work_pool.ecs_work_pool](https://registry.terraform.io/providers/prefecthq/prefect/latest/docs/resources/work_pool) | resource |
| [prefect_workspace.workspace](https://registry.terraform.io/providers/prefecthq/prefect/latest/docs/resources/workspace) | resource |
| [prefect_workspace_access.workspace_access](https://registry.terraform.io/providers/prefecthq/prefect/latest/docs/resources/workspace_access) | resource |
| [random_id.bucket](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [random_id.secret](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [aws_ecr_authorization_token.token](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ecr_authorization_token) | data source |
| [prefect_worker_metadata.d](https://registry.terraform.io/providers/prefecthq/prefect/latest/docs/data-sources/worker_metadata) | data source |
| [prefect_workspace_role.worker](https://registry.terraform.io/providers/prefecthq/prefect/latest/docs/data-sources/workspace_role) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | The AWS region to deploy the resources to. | `string` | n/a | yes |
| <a name="input_aws_subnet_ids"></a> [aws\_subnet\_ids](#input\_aws\_subnet\_ids) | The subnets to deploy the resources to. | `list(string)` | n/a | yes |
| <a name="input_aws_vpc_id"></a> [aws\_vpc\_id](#input\_aws\_vpc\_id) | The VPC to deploy the resources to. | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | The environment name. This is used to name most resources. | `string` | `"dev"` | no |
| <a name="input_flow_run_cpu"></a> [flow\_run\_cpu](#input\_flow\_run\_cpu) | The default CPU allocation for flow runs. | `number` | `1024` | no |
| <a name="input_flow_run_memory"></a> [flow\_run\_memory](#input\_flow\_run\_memory) | The default memory allocation for flow runs. | `number` | `2048` | no |
| <a name="input_prefect_account_id"></a> [prefect\_account\_id](#input\_prefect\_account\_id) | The Prefect account ID to create resources in. | `string` | n/a | yes |
| <a name="input_prefect_api_key"></a> [prefect\_api\_key](#input\_prefect\_api\_key) | The Prefect API key to use for creating resources. This key is not used by any of the resources created by this module. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_ecr_repository"></a> [aws\_ecr\_repository](#output\_aws\_ecr\_repository) | The AWS ECR repository base URL (for ECR login). |
| <a name="output_aws_region"></a> [aws\_region](#output\_aws\_region) | The AWS region (for ECR login). |
| <a name="output_environment"></a> [environment](#output\_environment) | The environment name. |
| <a name="output_prefect_workspace_url"></a> [prefect\_workspace\_url](#output\_prefect\_workspace\_url) | Check out your new workspace by clicking here. |
<!-- END_TF_DOCS -->