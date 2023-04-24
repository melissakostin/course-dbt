{{ 
    config(
        materialized='table'
    )
}}

with orders as (
    select * 
    from {{ ref ('stg_postgres_orders') }}
),

order_items as (
    select *
    from {{ ref ('stg_postgres_order_items') }}
),

promos as (
     select *
    from {{ ref ('stg_postgres_promos') }}   
),

final as (
    select
        orders.order_user_guid,
        orders.order_guid,
        order_items.order_item_quantity,
        promos.discount,
        orders.order_created_at,
        orders.order_cost,
        orders.order_shipping_cost,
        orders.order_total,
        orders.order_estimated_delivery_at,
        orders.order_delivered_at,
        datediff(day, order_estimated_delivery_at, order_delivered_at) as delivery_estimate_difference_days
    from orders
    join order_items on orders.order_guid = order_items.order_item_order_guid
    left join promos on promos.promo_guid = orders.order_promo_guid
)

select * 
from final