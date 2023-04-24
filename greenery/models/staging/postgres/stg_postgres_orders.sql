{{ 
    config(
        materialized='table'
    )
}}

SELECT
    order_id AS order_guid,
    promo_id AS order_promo_guid,
    user_id AS order_user_guid,
    address_id AS order_address_guid,
    created_at AS order_created_at,
    order_cost,
    shipping_cost AS order_shipping_cost,
    order_total,
    tracking_id AS order_tracking_guid,
    shipping_service AS order_shipping_service,
    estimated_delivery_at AS order_estimated_delivery_at,
    delivered_at AS order_delivered_at,
    status AS order_status
FROM {{ source('postgres', 'orders')}} 