{{ 
    config(
        materialized='table'
    )
}}

SELECT
    order_id AS order_item_order_guid,
    product_id AS order_item_product_guid,
    quantity AS order_item_quantity
FROM {{ source('postgres', 'order_items')}} 