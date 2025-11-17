#############################################
# AWS Temel Bilgiler
#############################################

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "eu-central-1"
}

variable "aws_profile" {
  description = "AWS CLI profile name"
  type        = string
  default     = "default"
}

#############################################
# Proje Temel Etiketleri
#############################################

variable "environment" {
  description = "Environment name (dev, stage, prod)"
  type        = string
  default     = "dev"
}

variable "project" {
  description = "Project name for resource tagging"
  type        = string
  default     = "picus-case"
}

#############################################
# VPC Değişkenleri
#############################################

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "Public subnet CIDR blocks"
  type        = list(string)
  default     = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]
}

variable "private_subnets" {
  description = "Private subnet CIDR blocks"
  type        = list(string)
  default     = [
    "10.0.3.0/24",
    "10.0.4.0/24"
  ]
}

#############################################
# ECS Ayarları
#############################################

variable "ecs_task_cpu" {
  description = "CPU units for ECS Task"
  type        = string
  default     = "256"
}

variable "ecs_task_memory" {
  description = "Memory for ECS Task (MiB)"
  type        = string
  default     = "512"
}

#############################################
# ALB Ayarları
#############################################

variable "alb_listener_port" {
  description = "ALB listener port"
  type        = number
  default     = 80
}

variable "container_port" {
  description = "Port exposed by container"
  type        = number
  default     = 8000
}

#############################################
# DynamoDB Ayarları
#############################################

variable "dynamodb_table_name" {
  description = "DynamoDB table name"
  type        = string
  default     = "picus"
}


variable "acm_certificate_arn" {
  description = "ACM certificate ARN for HTTPS listener"
  type        = string
}
