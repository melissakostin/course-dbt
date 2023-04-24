{{ 
    config(
        materialized='table'
    )
}}

SELECT
    event_id AS event_guid,
    session_id AS event_session_guid,
    user_id AS event_user_guid,
    event_type,
    page_url AS event_page_url,
    created_at AS event_created_at,
    order_id AS event_order_guid,
    product_id AS event_product_guid
FROM {{ source('postgres', 'events')}} 