{{ 
    config(
        materialized='table'
    )
}}

SELECT
    event_id AS event_guid,
    session_id,
    user_id,
    event_type,
    page_url,
    created_at,
    order_id,
    product_id
FROM {{ source('postgres', 'events')}} 