variable "name_prefix" {
  description = "Prefix for the name of resources"
  default     = "testing"
  type        = string
}

variable "component_data" {
  description = "Component data for software and configurations installation"
  type        = string
}

variable "recipe_description" {
  description = "Description for the image recipe"
  type        = string
}

variable "parent_image" {
  description = "Parent image for the image recipe"
  type        = string
  default = "ami-0430580de6244e02e"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-2"
}

variable "profile" {
  description = "AWS profile"
  type        = string
  default     = "default"
}

variable "additional_components" {
  description = "Additional components to be used in the image recipe"
  type        = list(string)
  default     = []
}

variable "default_tags" {
  description = "Default tags to be applied to AWS resources."
  type        = map(string)
  default     = {
    Environment   = "default" # This can be overridden to use var.profile or another variable
    ManagedBy     = "Terraform"
    ManagedByTeam = "DevOps"
    Project       = "Image Builder"
  }
}