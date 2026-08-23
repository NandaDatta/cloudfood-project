# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-cluster"

  setting {
    name = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name = "${var.project_name}-cluster"
    Environment = var.environment
  }
}

# Security group for ECS
resource "aws_security_group" "ecs" {
    name = "${var.project_name}-ecs-sg"
    description = "Security group for ECS tasks"
    vpc_id = aws_vpc.main.id

    ingress  {
        from_port = 5000
        to_port = 5000
        protocol = "tcp"
        security_groups = [aws_security_group.alb.id]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "${var.project_name}-ecs-sg"
    }
}

# ECS Task Definition
resource "aws_ecs_task_definition" "order_service" {
  family                   = "order-service"
  network_mode            = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                     = "256"
  memory                  = "512"
  execution_role_arn      = aws_iam_role.ecs_execution.arn
  task_role_arn          = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([
    {
      name  = "order-service"
      image = "${aws_ecr_repository.order_service.repository_url}:latest"
      essential = true
      
      portMappings = [
        {
          containerPort = 5000
          protocol     = "tcp"
        }
      ]
      
      environment = [
        { name = "DB_HOST", value = aws_db_instance.main.address },
        { name = "DB_USER", value = var.db_username },
        { name = "DB_PASS", value = var.db_password },
        { name = "DB_NAME", value = "testdb" },
        { name = "DB_PORT", value = "3306" },
        { name = "NODE_ENV", value = "production" }
      ]
      
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group" = "/ecs/order-service"
          "awslogs-region" = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

  tags = {
    Name        = "order-service"
    Environment = var.environment
  }
}

# ECS Service - UPDATED to use PUBLIC subnets
resource "aws_ecs_service" "order_service" {
  name            = "order-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.order_service.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = aws_subnet.public[*].id  # CHANGED: public subnets
    security_groups  = [aws_security_group.ecs.id]
    assign_public_ip = true  # CHANGED: true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.order_service.arn
    container_name   = "order-service"
    container_port   = 5000
  }

  depends_on = [aws_lb_listener.http]

  tags = {
    Name        = "order-service"
    Environment = var.environment
  }
}