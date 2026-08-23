# ECR Configuration
resource "aws_ecr_repository" "order_service" {
    name = "${var.project_name}-order_service"

    image_scanning_configuration {
        scan_on_push = true
    }

    tags = {
        Name = "${var.project_name}-order_service"
        Environment = var.environment
    }
}

resource "aws_ecr_repository" "payment_service" {
    name = "${var.project_name}-payment_service"

    image_scanning_configuration {
        scan_on_push = true
    }

    tags = {
        Name = "${var.project_name}-payment_service"
        Environment = var.environment
    }
}