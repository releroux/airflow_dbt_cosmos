
module "ec2_airflow" {
  source = "./modules/airflow"

  resource_prefix   = local.resource_prefix
  subnet_id         = local.subnet_ids
  security_group_id = local.security_group_ids[0]
  tags              = local.tags

  airflow_instance_type = local.airflow_instance_type
  airflow_instance_ami  = local.airflow_instance_ami
}

module "ec2_airflow_dags_dbt_files" {
  source = "./modules/upload"

  resource_prefix         = local.resource_prefix
  tags                    = local.tags
  aws_s3_bucket           = module.ec2_airflow.aws_s3_bucket
  airflow_dags_folder_key = module.ec2_airflow.airflow_dags_folder_key
  airflow_dbt_folder_key  = module.ec2_airflow.airflow_dbt_folder_key

  depends_on = [module.ec2_airflow]

}

# module "lambda" {
#   source = "./modules/lambda"

#   resource_prefix        = local.resource_prefix
#   subnet_ids             = local.subnet_ids
#   security_group_ids     = local.security_group_ids
#   lambda_runtime         = local.lambda_runtime
#   tags                   = local.tags
#   vpc_id                 = local.vpc_id
#   dag_name               = local.lambda_test_dag_id
#   airflow_ec2_public_dns = module.ec2_airflow.airflow_ec2_public_dns

#   depends_on = [module.ec2_airflow, module.ec2_airflow_dags_dbt_files]
# }


