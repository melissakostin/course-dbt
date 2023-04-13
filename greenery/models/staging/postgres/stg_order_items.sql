{{ 
    config(
        materialized='table'
    )
}}

SELECT
    order_id AS order_guid,
    product_id,
    quantity
FROM {{ source('postgres', 'order_items')}} 