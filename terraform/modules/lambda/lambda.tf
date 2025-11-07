# -----------------------------
# Build the Lambda function package
# -----------------------------
resource "null_resource" "build_lambda_package" {
  triggers = {
    source_code = filemd5("${path.module}/../../../src/lambda/lambda_function.py")
  }

  provisioner "local-exec" {
    command = <<EOF
      cd ${path.module}/../../../src/lambda
      zip -r lambda_function.zip lambda_function.py
    EOF
  }
}

# -----------------------------
# Creating Lambda Function
# -----------------------------
resource "aws_lambda_function" "lambda_dag_trigger" {
  function_name    = "${var.resource_prefix}-lambda-trigger-${var.dag_name}"
  role             = aws_iam_role.lambda_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = var.lambda_runtime
  filename         = "${path.module}/../../../src/lambda/lambda_function.zip"
  source_code_hash = filebase64sha256("${path.module}/../../../src/lambda/lambda_function.zip")

  timeout     = 120
  memory_size = 256

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = var.security_group_ids
  }

  environment {
    variables = {
      AIRFLOW_URL      = "http://${var.airflow_ec2_public_dns}:8080"
      AIRFLOW_USERNAME = "airflow"
      AIRFLOW_PASSWORD = "airflow" 
      DAG_NAME         = var.dag_name
    }
  }

  tags = var.tags

  depends_on = [
    null_resource.build_lambda_package
  ]
}
