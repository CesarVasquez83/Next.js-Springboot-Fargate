variable "aws_region" {
  default = "us-east-1"
}

variable "project_name" {
  default = "demo"
}

variable "db_username" {
  default = "postgres"
}

variable "db_password" {
  description = "Password para RDS"
  sensitive   = true
}