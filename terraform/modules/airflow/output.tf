# -----------------------------
# Outputs
# -----------------------------

output "aws_s3_bucket" {
  description = "S3 Bucket for Airflow DAGs and DBT files"
  value       = aws_s3_bucket.project_s3_bucket.id
}
output "airflow_dags_folder_key" {
  description = "S3 Folder for Airflow DAGs"
  value       = aws_s3_object.airflow_dags_folder.key
}

output "airflow_dbt_folder_key" {
  description = "S3 Folder for DBT files"
  value       = aws_s3_object.dbt_folder.key
}

output "airflow_ec2_public_dns" {
  description = "Public DNS of the Airflow EC2 instance"
  value       = aws_instance.airflow_ec2.public_dns
}

output "airflow_http_link" {
  description = "HTTP link to access Airflow UI"
  value       = "http://${aws_instance.airflow_ec2.public_dns}:8080"
}