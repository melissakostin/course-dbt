{{ 
    config(
        materialized='table'
    )
}}

with session_events_agg as (
    select * 
    from {{ ref ('int_session_events_agg') }}
),

users as (
    select *
    from {{ ref ('stg_postgres_users') }}
)

select  
    session_events_agg.event_session_guid,
    session_events_agg.event_user_guid,
    users.user_first_name,
    users.user_last_name,
    users.user_email,
    session_events_agg.add_to_carts,
    session_events_agg.checkouts,
    session_events_agg.package_shippeds,
    session_events_agg.page_views,
    session_events_agg.first_session_event_at as first_session_event,
    session_events_agg.last_session_event_at as last_session_event,
    datediff('minute',first_session_event, last_session_event) as session_length_minutes
from session_events_agg
left join users on users.user_guid = session_events_agg.event_user_guid