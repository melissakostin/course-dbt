{{ 
    config(
        materialized='table'
    )
}}

SELECT
    product_id AS product_guid,
    name AS product_name,
    price AS product_price,
    inventory AS product_inventory
FROM {{ source('postgres', 'products')}} 