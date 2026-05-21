variable "aws_region" {
  description = "AWS region for the state bucket"
  type        = string
  default     = "ap-southeast-5"
}

variable "state_bucket_name" {
  description = "Globally unique S3 bucket name for Terraform state (e.g. 123456789012-email-crud-terraform-state)"
  type        = string
}
