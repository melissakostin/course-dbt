{{ 
    config(
        materialized='table'
    )
}}

with session_events as (
    select *
    from {{ ref ('int_session_events_agg') }}
),

checkout_orders as (
    select *
    from {{ ref ('int_checkout_orders') }}
),

final as (
    select 
        session_events.event_session_guid,
        session_events.event_product_guid,
        checkout_orders.order_item_product_guid,
        checkout_orders.product_name,
        checkout_orders.event_session_guid as event_session_checkout,
        checkout_orders.order_item_quantity
    from session_events
    left join checkout_orders on checkout_orders.order_item_product_guid = session_events.event_product_guid
)

select *
from final