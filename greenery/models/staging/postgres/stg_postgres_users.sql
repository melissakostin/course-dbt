{{ 
    config(
        materialized='table'
    )
}}

SELECT
    user_id AS user_guid,
    first_name AS user_first_name,
    last_name AS user_last_name,
    email AS user_email,
    phone_number AS user_phone_number,
    created_at AS user_created_at,
    updated_at AS user_updated_at,
    address_id AS user_address_guid
FROM {{ source('postgres', 'users')}} 