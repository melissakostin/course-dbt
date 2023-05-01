{{ 
    config(
        materialized='table'
    )
}}

with events as (
    select * 
    from {{ ref ('stg_postgres_events') }}
),

order_items as (
    select * 
    from {{ ref ('stg_postgres_order_items') }}  
),

products as (
    select * 
    from {{ ref ('stg_postgres_products') }}     
),

final as (
    select
        events.event_guid,
        events.event_session_guid,
        events.event_order_guid,
        order_items.order_item_order_guid,
        order_items.order_item_product_guid,
        products.product_name,
        order_items.order_item_quantity
    from events
    join order_items on order_items.order_item_order_guid = events.event_order_guid
    join products on products.product_guid = order_items.order_item_product_guid
    where event_type = 'checkout'
)

select *
from final