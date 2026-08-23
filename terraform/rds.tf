resource "aws_db_subnet_group" "main" {
  name       = "${var.environment}-db-subnet-group"
  subnet_ids = aws_subnet.private[*].id

  tags = {
    Name = "${var.project_name}-db-subnet-group"
  }
}

resource "aws_security_group" "rds" {
  name        = "${var.project_name}-rds-sg"
  description = "Security group for RDS"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs.id]
  }

  tags = {
    Name = "${var.project_name}-rds-sg"
  }
}

resource "aws_db_instance" "main" {
  identifier = "${var.project_name}-db"
  
  engine         = "mysql"
  engine_version = "8.0"
  instance_class = "db.t3.micro"        # Free tier eligible
  allocated_storage = 20                 # Free tier (20GB max)
  
  db_name  = "testdb"
  username = var.db_username
  password = var.db_password
  
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  
  # FREE TIER COMPATIBLE - Max 7 days retention
  backup_retention_period = 1            # Changed from 7 to 1 day
  backup_window          = "03:00-04:00"
  maintenance_window     = "sun:04:00-sun:05:00"
  
  # Skip final snapshot to avoid extra charges
  skip_final_snapshot = true
  deletion_protection = false
  
  # Additional Free Tier optimizations
  enabled_cloudwatch_logs_exports = ["general", "error", "slowquery"]
  performance_insights_enabled = false  # Disable to save cost
  monitoring_interval = 0               # Disable monitoring to save cost
  
  tags = {
    Name        = "${var.project_name}-db"
    Environment = var.environment
  }
}