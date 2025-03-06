variable "environment" {
  description = "The environment name. This is used to name most resources."
  type        = string
  default     = "dev"
}

variable "prefect_account_id" {
  description = "The Prefect account ID to create resources in."
  type        = string
}

variable "prefect_api_key" {
  description = "The Prefect API key to use for creating resources. This key is not used by any of the resources created by this module."
  type        = string
  sensitive   = true
}

variable "aws_region" {
  description = "The AWS region to deploy the resources to."
  type        = string
}

variable "aws_vpc_id" {
  description = "The VPC to deploy the resources to."
  type        = string
}

variable "aws_subnet_ids" {
  description = "The subnets to deploy the resources to."
  type        = list(string)
}

variable "flow_run_cpu" {
  description = "The default CPU allocation for flow runs."
  type        = number
  default     = 1024
}

variable "flow_run_memory" {
  description = "The default memory allocation for flow runs."
  type        = number
  default     = 2048
}

