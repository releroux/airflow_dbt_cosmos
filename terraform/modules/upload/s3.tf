resource "aws_s3_object" "dags" {
  for_each = fileset("${path.module}/../../../dags", "**/*")

  bucket = var.aws_s3_bucket
  key    = "${var.airflow_dags_folder_key}/${each.value}"
  source = "${path.module}/../../../dags/${each.value}"
  etag   = filemd5("${path.module}/../../../dags/${each.value}")
}

resource "aws_s3_object" "dbt" {
  for_each = fileset("${path.module}/../../../dbt", "**/*")

  bucket = var.aws_s3_bucket
  key    = "${var.airflow_dbt_folder_key}/${each.value}"
  source = "${path.module}/../../../dbt/${each.value}"
  etag   = filemd5("${path.module}/../../../dbt/${each.value}")
}
