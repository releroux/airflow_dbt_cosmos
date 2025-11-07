variable "resource_prefix" {
  description = "Prefix for naming AWS resources"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC where resources will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for deploying resources"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs to associate with resources"
  type        = list(string)
}

variable "tags" {
  description = "A map of tags to assign to resources"
  type        = map(string)
}

variable "lambda_runtime" {
  description = "Runtime environment for the Lambda function"
  type        = string
}

variable "dag_name" {
  description = "Name of the DAG to be triggered in MWAA"
  type        = string
}

variable "airflow_ec2_public_dns" {
  description = "Public DNS of the Airflow EC2 instance"
  type        = string
}
