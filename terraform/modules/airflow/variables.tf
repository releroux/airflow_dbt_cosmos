variable "resource_prefix" {
  description = "Prefix for naming AWS resources"
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to resources"
  type        = map(string)
}

variable "subnet_id" {
  description = "Existing subnet ID where instance should be launched"
  type        = list(string)
}

variable "security_group_id" {
  description = "Existing security group ID allowing SSH and port 8080"
  type        = string
}

variable "airflow_instance_type" {
  description = "EC2 instance type for Airflow"
  type        = string
  
}

variable "airflow_instance_ami" {
  description = "AMI ID for Airflow EC2 instance"
  type        = string
}