output "alb_dns_name" {
  description = "ALB DNS name"
  value       = aws_lb.main.dns_name
}

output "ecr_repository_order" {
  description = "ECR repository URL for order service"
  value       = aws_ecr_repository.order_service.repository_url
}

output "ecr_repository_payment" {
  description = "ECR repository URL for payment service"
  value       = aws_ecr_repository.payment_service.repository_url
}

output "rds_endpoint" {
  description = "RDS endpoint"
  value       = aws_db_instance.main.endpoint
  sensitive   = true
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = aws_ecs_cluster.main.name
}