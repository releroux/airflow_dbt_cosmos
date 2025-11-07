variable "resource_prefix" {
  description = "Prefix for naming AWS resources"
  type        = string
  default     = null
}

variable "vpc_id" {
  description = "The ID of the VPC where resources will be deployed"
  type        = string
  default     = null
}

variable "subnet_ids" {
  description = "List of subnet IDs for deploying resources"
  type        = list(string)
  default     = null
}

variable "security_group_ids" {
  description = "List of security group IDs to associate with resources"
  type        = list(string)
  default     = null
}

variable "tags" {
  description = "A map of tags to assign to resources"
  type        = map(string)
  default     = null
}

# variable "lambda_runtime" {
#   description = "Runtime environment for the Lambda function"
#   type        = string
#   default     = null
# }

# variable "airflow_instance_type" {
#   description = "EC2 instance type for Airflow"
#   type        = string
#   default     = null  
# }

# variable "airflow_instance_ami" {
#   description = "AMI ID for Airflow EC2 instance"
#   type        = string
#   default     = null
# }