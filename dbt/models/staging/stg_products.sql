{{
    config(
        location = 's3://cat-rnd-mwaa-dbt-bucket/data/stg_products/',
        unique_keys = ['product_id']
    )
}}

SELECT 
    CAST(product_id AS VARCHAR) AS product_id,
    product_description 
FROM {{ref('sales_data')}}
GROUP BY 
    CAST(product_id AS VARCHAR), 
    product_description