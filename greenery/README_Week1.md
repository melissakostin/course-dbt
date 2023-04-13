How many users do we have? **130**
```
select 
    count(user_guid) as users
from stg_users;
```


On average, how many orders do we receive per hour? **7.5**
```
with orders_per_hour as (
    select 
        date(created_at),
        hour(created_at), 
        count(order_guid) as orders
from stg_orders
group by 1,2)

select 
    round(avg(orders),1) as avg_orders
from orders_per_hour;
```


On average, how long does an order take from being placed to being delivered? **3.9 days**
```
with delivery_time as 
(
    select 
        order_guid, 
        created_at, 
        delivered_at,
        datediff(day, created_at, delivered_at) as days_to_deliver
    from stg_orders
    where delivered_at is not null
)

select round(avg(days_to_deliver),1) as avg_delivery
from delivery_time;
```


How many users have only made one purchase? Two purchases? Three+ purchases? **25, 28, 71**
```
with purchase_counts as 
(
    select 
        user_guid, 
        count(order_guid) as purchases
    from stg_users
    inner join stg_orders on stg_orders.user_id = stg_users.user_guid
    group by 1 
)

select 
    count(case when purchases = 1 then user_guid end) as "1 Purchase",
    count(case when purchases = 2 then user_guid end) as "2 Purchases",
    count(case when purchases >= 3 then user_guid end) as "3+ Purchases"
from purchase_counts;
```


On average, how many unique sessions do we have per hour? **16.3**
```
with sessions_per_hour as 
(
    select 
        date(created_at), 
        hour(created_at) as hour, 
        count(distinct session_id) as unique_sessions
from stg_events
group by 1,2
)

select round(avg(unique_sessions),1) as avg_sessions
from sessions_per_hour;
```