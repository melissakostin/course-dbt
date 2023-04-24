{{ 
    config(
        materialized='table'
    )
}}

with products as (
    select *
    from {{ ref ('stg_postgres_products') }}
),

order_items as (
    select *
    from {{ ref ('stg_postgres_order_items') }}
),

events as (
    select *
    from {{ ref ('stg_postgres_events') }}    
)

select
    products.product_guid,
    products.product_name,
    products.product_price,
    products.product_inventory,
    sum(order_items.order_item_quantity) as total_product_orders,
    count(events.event_session_guid) as total_session_events
from products
inner join order_items on order_items.order_item_product_guid = products.product_guid
inner join events on events.event_product_guid = products.product_guid
group by 1,2,3,4