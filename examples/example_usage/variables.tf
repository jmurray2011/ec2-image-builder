variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-2"
}

variable "component_data" {
  description = "Component data for software and configurations installation"
  type        = string
}
