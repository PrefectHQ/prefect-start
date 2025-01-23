terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    // Used for building and pushing the worker image
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
    prefect = {
      source  = "prefecthq/prefect"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_ecr_authorization_token" "token" {}
provider "docker" {
  host = "unix:///var/run/docker.sock"
  registry_auth {
    address  = data.aws_ecr_authorization_token.token.proxy_endpoint
    username = data.aws_ecr_authorization_token.token.user_name
    password = data.aws_ecr_authorization_token.token.password
  }
}

provider "prefect" {
  account_id = var.prefect_account_id
  api_key    = var.prefect_api_key
}