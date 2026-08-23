# IAM Roles

# ECS execution role
resource "aws_iam_role" "ecs_execution" {
    name = "${var.project_name}-ecs-execution-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"  # Fixed: was 2012-10-27
        Statement = [
            {
                Action = "sts:AssumeRole"
                Effect = "Allow"
                Principal = {
                    Service = "ecs-tasks.amazonaws.com"
                }
            }
        ]
    })

    tags = {
      Name = "${var.project_name}-ecs-execution-role"
      Environment = var.environment
    }
}

# ECS Execution Role Policy
resource "aws_iam_role_policy_attachment" "ecs_execution" {
  role       = aws_iam_role.ecs_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ECS Task Role
resource "aws_iam_role" "ecs_task" {
  name = "${var.project_name}-ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-ecs-task-role"
    Environment = var.environment
  }
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/order-service"
  retention_in_days = 7

  tags = {
    Name        = "order-service-logs"
    Environment = var.environment
  }
}