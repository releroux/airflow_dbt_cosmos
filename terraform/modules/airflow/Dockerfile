FROM apache/airflow:3.1.1

USER root

# Install system dependencies if needed
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

USER airflow


# Uninstall unnecessary packages that come with base Airflow image
RUN pip uninstall -y \
    opentelemetry-exporter-prometheus \
    snowflake-snowpark-python \
    snowflake-connector-python \
    apache-airflow-providers-snowflake || true


# Install dbt-core, dbt-athena, and astronomer-cosmos
RUN pip install --no-cache-dir \
    astronomer-cosmos \
    dbt-core \
    dbt-athena-community \
    apache-airflow-providers-openlineage