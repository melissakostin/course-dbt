{{ 
    config(
        materialized='table'
    )
}}

select 
    event_user_guid,
    event_session_guid,
    sum(page_views) as page_views
from {{ ref ('int_session_events_agg') }}
group by 1,2