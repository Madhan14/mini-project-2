variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Project name prefix"
  type        = string
  default     = "trend"
}

variable "ami_id" {
  description = "AMI ID for EC2"
  type        = string
  default     = "ami-0dee22c13ea7a9a67" # Amazon Linux 2 (Mumbai region example)
}

variable "instance_type" {
  description = "EC2 instance type for Jenkins"
  type        = string
  default     = "t3.medium"
}

variable "ssh_key_name" {
  description = "Name of the AWS key pair for SSH"
  type        = string
}

variable "dockerhub_username" {
  description = "DockerHub username"
  type        = string
}

variable "dockerhub_repo" {
  description = "DockerHub repository name"
  type        = string
}

