// Resources
// ECR for storing flow code in images
// ECS for hosting the worker and running flows
// S3 for storing data


// ECR
resource "aws_ecr_repository" "prefect_worker_image" {
  name         = "prefect-worker-${var.environment}"
  force_delete = true
}

resource "aws_ecr_repository" "prefect_flow_image" {
  name         = "prefect-flow-${var.environment}"
  force_delete = true
}


// Build and push the worker image
// https://stackoverflow.com/a/76608435
resource "docker_image" "prefect_worker_image" {
  name = "${aws_ecr_repository.prefect_worker_image.repository_url}:latest"
  build {
    context    = "."
    dockerfile = "../../Dockerfile.worker"
    platform   = "linux/amd64"
  }
  triggers = {
    dockerfile = sha1(file("../../Dockerfile.worker"))
  }
}

resource "docker_registry_image" "prefect_worker_image" {
  name          = docker_image.prefect_worker_image.name
  keep_remotely = true
}


// Secrets Manager
resource "random_id" "secret" {
  byte_length = 8
}

resource "aws_secretsmanager_secret" "prefect_api_key" {
  name                    = "prefect-worker-${var.environment}-api-key-${random_id.secret.hex}"
  recovery_window_in_days = 7
}

resource "aws_secretsmanager_secret_version" "prefect_api_key_version" {
  secret_id     = aws_secretsmanager_secret.prefect_api_key.id
  secret_string = prefect_service_account.service_account.api_key
}


// S3
resource "random_id" "bucket" {
  byte_length = 8
}

resource "aws_s3_bucket" "prefect_storage" {
  bucket = "prefect-storage-${var.environment}-${random_id.bucket.hex}"
}

// Enable event notifications for later consumption as events
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket      = aws_s3_bucket.prefect_storage.id
  eventbridge = true
}


// IAM
resource "aws_iam_role" "prefect_worker_execution_role" {
  name = "prefect-worker-${var.environment}-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy" "prefect_worker_execution_policy" {
  name = "prefect-worker-${var.environment}-execution-policy"
  role = aws_iam_role.prefect_worker_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "kms:Decrypt",
          "secretsmanager:GetSecretValue",
          "ssm:GetParameters"
        ]
        Effect = "Allow"
        Resource = [
          aws_secretsmanager_secret.prefect_api_key.arn
        ]
      },
      {
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "prefect_worker_task_role" {
  name = "prefect-worker-${var.environment}-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy" "prefect_worker_task_policy" {
  name = "prefect-worker-${var.environment}-task-policy"
  role = aws_iam_role.prefect_worker_task_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:DescribeSubnets",
          "ec2:DescribeVpcs",
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:GetAuthorizationToken",
          "ecr:GetDownloadUrlForLayer",
          "ecs:DeregisterTaskDefinition",
          "ecs:DescribeTaskDefinition",
          "ecs:DescribeTasks",
          "ecs:RegisterTaskDefinition",
          "ecs:RunTask",
          "ecs:StopTask",
          "ecs:TagResource",
          "iam:PassRole",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:GetLogEvents",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "prefect_flow_execution_role" {
  name = "prefect-flow-${var.environment}-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy" "prefect_flow_execution_policy" {
  name = "prefect-flow-${var.environment}-execution-policy"
  role = aws_iam_role.prefect_flow_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "prefect_flow_task_role" {
  name = "prefect-flow-${var.environment}-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy" "prefect_flow_task_policy" {
  name = "prefect-flow-${var.environment}-task-policy"
  role = aws_iam_role.prefect_flow_task_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Effect = "Allow"
        Resource = [
          aws_s3_bucket.prefect_storage.arn,
          "${aws_s3_bucket.prefect_storage.arn}/*"
        ]
      }
    ]
  })
}

// Networking
resource "aws_security_group" "prefect_sg" {
  name        = "prefect-${var.environment}-sg"
  description = "Egress for ${var.environment} Prefect worker and flow runs on ECS"
  vpc_id      = var.aws_vpc_id
}

resource "aws_security_group_rule" "http_outbound" {
  description       = "HTTP outbound"
  type              = "egress"
  security_group_id = aws_security_group.prefect_sg.id
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "https_outbound" {
  description       = "HTTPS outbound"
  type              = "egress"
  security_group_id = aws_security_group.prefect_sg.id
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

// ECS
resource "aws_ecs_cluster" "prefect_worker_cluster" {
  name = "prefect-worker-${var.environment}"
}

resource "aws_ecs_cluster_capacity_providers" "prefect_worker_cluster_capacity_providers" {
  cluster_name       = aws_ecs_cluster.prefect_worker_cluster.name
  capacity_providers = ["FARGATE"]
}

resource "aws_cloudwatch_log_group" "prefect_worker_log_group" {
  name              = "prefect-worker-${var.environment}-log-group"
  retention_in_days = 30
}

resource "aws_ecs_task_definition" "prefect_worker_task_definition" {
  family = "prefect-worker-${var.environment}"
  cpu    = 1024
  memory = 2048

  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  container_definitions = jsonencode([
    {
      name  = "prefect-worker-${var.environment}"
      image = "${aws_ecr_repository.prefect_worker_image.repository_url}:latest"
      // TODO: Should we enforce a limit on flow runs at the worker level, if so what?
      command = ["prefect", "worker", "start", "--pool", "ecs", "--type", "ecs"]
      environment = [
        {
          name  = "PREFECT_API_URL"
          value = "https://api.prefect.cloud/api/accounts/${var.prefect_account_id}/workspaces/${prefect_workspace.workspace.id}"
        }
      ]
      secrets = [
        {
          name      = "PREFECT_API_KEY"
          valueFrom = aws_secretsmanager_secret.prefect_api_key.arn
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.prefect_worker_log_group.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "prefect-worker-${var.environment}"
        }
      }
    }
  ])
  // Execution role allows ECS to create tasks and services
  execution_role_arn = aws_iam_role.prefect_worker_execution_role.arn
  // Task role allows tasks and services to access other AWS resources
  task_role_arn = aws_iam_role.prefect_worker_task_role.arn
}

resource "aws_ecs_service" "prefect_worker_service" {
  name          = "prefect-worker-${var.environment}"
  cluster       = aws_ecs_cluster.prefect_worker_cluster.id
  desired_count = 1
  launch_type   = "FARGATE"

  // Public IP required for secrets, images, and communicating with Prefect API
  // https://docs.aws.amazon.com/AmazonECS/latest/developerguide/fargate-task-networking.html
  network_configuration {
    security_groups  = [aws_security_group.prefect_sg.id]
    assign_public_ip = true
    subnets          = var.aws_subnet_ids
  }
  task_definition = aws_ecs_task_definition.prefect_worker_task_definition.arn

  // Wait for the work pool to be created in Prefect Cloud before starting the service
  depends_on = [prefect_work_pool.ecs_work_pool]
}