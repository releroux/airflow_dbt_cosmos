# -----------------------------
# S3 Bucket for Airflow DAGs and DBT files
# -----------------------------
resource "aws_s3_bucket" "project_s3_bucket" {
  bucket        = "${var.resource_prefix}-bucket"
  force_destroy = true
  tags          = var.tags
}

resource "aws_s3_object" "airflow_dags_folder" {
  bucket        = aws_s3_bucket.project_s3_bucket.id
  force_destroy = true
  key           = "airflow/dags/"
}
resource "aws_s3_object" "dbt_folder" {
  bucket        = aws_s3_bucket.project_s3_bucket.id
  force_destroy = true
  key           = "airflow/dbt/"
}

