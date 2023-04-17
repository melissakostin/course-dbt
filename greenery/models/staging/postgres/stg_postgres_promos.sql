{{ 
    config(
        materialized='table'
    )
}}

SELECT
    promo_id AS promo_guid,
    discount,
    status
FROM {{ source('postgres', 'promos')}} 