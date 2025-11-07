# -----------------------------
# IAM Role for EC2 to access S3
# -----------------------------
resource "aws_iam_role" "airflow_ec2_role" {
  name = "${var.resource_prefix}-airflow-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

# -----------------------------
# S3 Policy for DAGs and dbt files
# -----------------------------
resource "aws_iam_role_policy" "airflow_s3_policy" {
  name = "${var.resource_prefix}-airflow-s3-policy"
  role = aws_iam_role.airflow_ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "s3:*"
      ]
      Resource = [
        "${aws_s3_bucket.project_s3_bucket.arn}",
        "${aws_s3_bucket.project_s3_bucket.arn}/*"
      ]
    }]
  })
}

# -----------------------------
# Athena Policy for dbt-athena
# -----------------------------
resource "aws_iam_role_policy" "airflow_athena_policy" {
  name = "${var.resource_prefix}-airflow-athena-policy"
  role = aws_iam_role.airflow_ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "athena:*",
      ]
      Resource = [
        "arn:aws:athena:*:*:workgroup/*",
        "arn:aws:athena:*:*:datacatalog/*"
      ]
    }]
  })
}

# -----------------------------
# Glue Policy for dbt metadata operations
# -----------------------------
resource "aws_iam_role_policy" "airflow_glue_policy" {
  name = "${var.resource_prefix}-airflow-glue-policy"
  role = aws_iam_role.airflow_ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "glue:*",
      ]
      Resource = [
        "arn:aws:glue:*:*:catalog",
        "arn:aws:glue:*:*:database/*",
        "arn:aws:glue:*:*:table/*"
      ]
    }]
  })
}

# -----------------------------
# CloudWatch Logs (optional but recommended for debugging)
# -----------------------------
resource "aws_iam_role_policy" "airflow_logs_policy" {
  name = "${var.resource_prefix}-airflow-logs-policy"
  role = aws_iam_role.airflow_ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "logs:*",
      ]
      Resource = "arn:aws:logs:*:*:log-group:/aws/airflow/*"
    }]
  })
}

resource "aws_iam_instance_profile" "airflow_profile" {
  name = "${var.resource_prefix}-airflow-profile"
  role = aws_iam_role.airflow_ec2_role.name
}