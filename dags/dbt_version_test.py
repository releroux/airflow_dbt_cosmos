from airflow import DAG
from cosmos import DbtDag, ProjectConfig, ProfileConfig, ExecutionConfig
from cosmos.constants import ExecutionMode
from datetime import datetime, timedelta
from pathlib import Path

# Default arguments for the DAG
default_args = {
    "owner": "airflow",
    "depends_on_past": False,
    "email_on_failure": False,
    "email_on_retry": False,
    "retries": 0
}

# Path to your dbt project
DBT_PROJECT_PATH = Path("/opt/airflow/dbt")
DBT_PROFILES_PATH = Path("/opt/airflow/dbt")

# Create the Cosmos DAG
dbt_cosmos_dag = DbtDag(
    # DAG configuration
    dag_id="dbt_cosmos_test",
    description="dbt project managed by Astronomer Cosmos",
    default_args=default_args,
    start_date=datetime(2025, 1, 1),
    catchup=False,
    tags=["dbt", "cosmos", "sales"],
    
    # dbt project configuration
    project_config=ProjectConfig(
        dbt_project_path=DBT_PROJECT_PATH,
    ),
    
    # Profile configuration for Athena
    profile_config=ProfileConfig(
        profile_name="default",
        target_name="dev",
        profiles_yml_filepath=DBT_PROFILES_PATH / "profiles.yml",
    ),
    
    # Execution configuration
    execution_config=ExecutionConfig(
        dbt_executable_path="/home/airflow/.local/bin/dbt",
        execution_mode=ExecutionMode.LOCAL,
    ),
    
    # Render dbt models as Airflow tasks
    operator_args={
        "install_deps": True,
        "emit_datasets": False,  # ADD THIS LINE - Disables OpenLineage
    },
)