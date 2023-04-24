select *
from {{ ref ('stg_postgres_users') }}
where length(user_phone_number) != 12