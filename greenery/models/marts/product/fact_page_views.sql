{{ 
    config(
        materialized='table'
    )
}}

select 
    event_user_guid,
    event_session_guid,
    datediff(day, last_session_event_at, current_date) as days_since_last_session,
    sum(page_views) as page_views
from {{ ref ('int_session_events_agg') }}
group by 1,2,3