{{
    config(
        location = 's3://cat-rnd-mwaa-dbt-bucket/data/mart_sales/',
        unique_keys = ['uuid'],
        partition_by = ['sale_date']
    )
}}

WITH customers AS (
    SELECT * 
    FROM {{ref('stg_customers')}}
),
products AS (
    SELECT * 
    FROM {{ref('stg_products')}}
),
sales AS (
    SELECT * 
    FROM {{ref('stg_sales')}}
)
SELECT 
    s.uuid,
    s.sale_date,
    c.customer_id,
    c.customer_name,
    p.product_id,
    p.product_description,
    s.sale_amount AS sales_amount_dollars
FROM sales s
LEFT JOIN customers c ON s.customer_id = c.customer_id
LEFT JOIN products p ON s.product_id = p.product_id
