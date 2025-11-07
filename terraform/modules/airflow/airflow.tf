# -----------------------------
# EC2 Instance for Airflow + dbt
# -----------------------------
resource "aws_instance" "airflow_ec2" {
  ami                         = var.airflow_instance_ami
  instance_type               = var.airflow_instance_type
  subnet_id                   = var.subnet_id[0]
  key_name                    = aws_key_pair.airflow_key.key_name
  vpc_security_group_ids      = [var.security_group_id]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.airflow_profile.name

  user_data = templatefile("${path.module}/user_data.sh", {
    s3_dags_path           = "s3://${aws_s3_bucket.project_s3_bucket.id}/${aws_s3_object.airflow_dags_folder.key}"
    s3_dbt_path            = "s3://${aws_s3_bucket.project_s3_bucket.id}/${aws_s3_object.dbt_folder.key}"
    docker_compose_content = data.local_file.docker_compose.content
    dockerfile_content     = data.local_file.dockerfile.content
  })

  root_block_device {
    volume_size = 30
  }

  tags = {
    Name = "${var.resource_prefix}-airflow-ec2"
  }

  depends_on = [tls_private_key.airflow_key, aws_key_pair.airflow_key]
}

# -----------------------------
# Key Pair for EC2 Instance
# -----------------------------
resource "tls_private_key" "airflow_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "airflow_key" {
  key_name   = "airflow-poc-key"
  public_key = tls_private_key.airflow_key.public_key_openssh
}

# -----------------------------
# Dockerfile for Airflow + dbt
# -----------------------------
data "local_file" "dockerfile" {
  filename = "${path.module}/Dockerfile"
}
data "local_file" "docker_compose" {
  filename = "${path.module}/docker-compose.yaml"
}
