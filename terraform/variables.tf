# Variables

variable "aws_region" {
    description = "AWS region"
    type = string
    default = "us-east-1"
}

variable "project_name" {
    description = "Project name"
    type = string
    default = "dev"
}

variable "environment" {
    description = "Environment name"
    type = string
    default = "dev"
}

variable "db_username" {
  description = "Database username"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}