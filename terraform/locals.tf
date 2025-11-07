# -----------------------------
# Load configuration from YAML file
# -----------------------------
locals {
  config = yamldecode(file("${path.root}/../config.yaml"))

  resource_prefix    = local.config.general.resource_prefix
  vpc_id             = local.config.general.vpc_id
  subnet_ids         = local.config.general.subnet_ids
  security_group_ids = local.config.general.security_group_ids
  tags               = local.config.general.tags

  airflow_instance_type = local.config.airflow.instance_type
  airflow_instance_ami  = local.config.airflow.ami

  lambda_runtime     = local.config.lambda.lambdaRuntime
  lambda_test_dag_id = local.config.lambda.test_dag_id
}
