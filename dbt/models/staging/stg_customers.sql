{{
    config(
        location = 's3://cat-rnd-mwaa-dbt-bucket/data/stg_customers/',
        unique_keys = ['customer_id']
    )
}}

SELECT 
    CAST(customer_id AS VARCHAR) AS customer_id,
    customer_name
FROM {{ref('sales_data')}}
GROUP BY 
    CAST(customer_id AS VARCHAR),
    customer_name