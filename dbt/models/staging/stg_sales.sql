{{
    config(
        location = 's3://cat-rnd-mwaa-dbt-bucket/data/stg_sales/',
        unique_keys = ['uuid'],
        partition_by = ['sale_date']
    )
}}

SELECT 
    CAST(uuid AS VARCHAR) AS uuid,
    CAST(sale_date AS DATE) AS sale_date,
    CAST(customer_id AS VARCHAR) AS customer_id,
    CAST(product_id AS VARCHAR) AS product_id,
    CAST(sale_amount AS DECIMAL(10, 2)) AS sale_amount
FROM {{ref('sales_data')}}
WHERE sale_amount > 0