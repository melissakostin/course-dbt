{{ 
    config(
        materialized='table'
    )
}}

{%- set event_types = dbt_utils.get_column_values(
    table = ref('stg_postgres_events'),
    column = 'event_type'
    )
%}

select
    event_user_guid
    , event_session_guid
    , event_created_at
    , event_order_guid
    , event_product_guid
    {%- for event_type in event_types %}
        , sum(case when event_type = '{{ event_type }}' then 1 else 0 end) as {{ event_type }}s 
    {%- endfor %}
from {{ ref ('stg_postgres_events') }}
group by 1,2,3,4,5