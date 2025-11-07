variable "resource_prefix" {
  description = "Prefix for naming AWS resources"
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to resources"
  type        = map(string)
}

variable "aws_s3_bucket" {
    description = "S3 Bucket for Airflow DAGs and DBT files"
    type        = string
}

variable "airflow_dags_folder_key" {
    description = "S3 key for the Airflow DAGs folder"
    type        = string
}

variable "airflow_dbt_folder_key" {
    description = "S3 key for the Airflow DBT folder"
    type        = string
}