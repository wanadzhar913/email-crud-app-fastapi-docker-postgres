variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Short project name used in resource naming"
  type        = string
  default     = "email-crud"
}

variable "environment" {
  description = "Environment label (e.g. prod, staging)"
  type        = string
  default     = "prod"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "db_name" {
  description = "PostgreSQL database name"
  type        = string
  default     = "fastapi_database"
}

variable "db_username" {
  description = "PostgreSQL master username"
  type        = string
  default     = "myuser"
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t4g.micro"
}

variable "db_engine_version" {
  description = "PostgreSQL engine version for RDS"
  type        = string
  default     = "17.4"
}

variable "image_tag" {
  description = "Docker image tag for ECS task definitions"
  type        = string
  default     = "latest"
}

variable "backend_cpu" {
  description = "Fargate CPU units for backend task (1024 = 1 vCPU)"
  type        = number
  default     = 256
}

variable "backend_memory" {
  description = "Fargate memory (MiB) for backend task"
  type        = number
  default     = 512
}

variable "frontend_cpu" {
  description = "Fargate CPU units for frontend task"
  type        = number
  default     = 256
}

variable "frontend_memory" {
  description = "Fargate memory (MiB) for frontend task"
  type        = number
  default     = 512
}

variable "desired_count" {
  description = "Number of tasks per ECS service"
  type        = number
  default     = 1
}

variable "github_repository" {
  description = "GitHub repo in OWNER/NAME form for OIDC trust (e.g. myuser/email-crud-app)"
  type        = string
}

variable "terraform_state_bucket" {
  description = "S3 bucket name for Terraform remote state (must match backend.hcl)"
  type        = string
}

variable "project_title" {
  description = "App title exposed via /api/project/"
  type        = string
  default     = "Email CRUD App"
}

variable "project_version" {
  description = "App version exposed via /api/project/"
  type        = string
  default     = "0.1.0"
}

variable "project_description" {
  description = "App description exposed via /api/project/"
  type        = string
  default     = "A simple CRUD app for emails. Deployed on AWS ECS."
}
