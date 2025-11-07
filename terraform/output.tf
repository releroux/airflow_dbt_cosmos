# -----------------------------
# Outputs
# -----------------------------
# output "airflow_ec2_public_ip" {
#   description = "Public IP of the Airflow EC2 instance"
#   value       = module.ec2_airflow.airflow_ec2_public_ip
# }

output "aws_s3_bucket" {
  description = "S3 Bucket for Airflow DAGs and DBT files"
  value       = module.ec2_airflow.aws_s3_bucket
}

output "airflow_dags_folder_key" {
  description = "S3 Folder for Airflow DAGs"
  value       = module.ec2_airflow.airflow_dags_folder_key
}

output "airflow_dbt_folder_key" {
  description = "S3 Folder for DBT files"
  value       = module.ec2_airflow.airflow_dbt_folder_key
}

output "airflow_http_link" {
  description = "HTTP link to access Airflow UI"
  value       = module.ec2_airflow.airflow_http_link
}