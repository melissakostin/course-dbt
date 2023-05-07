# Week 1 Questions

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


# Week 2 Questions

## Part 1. Models
**What is our user repeat rate?** 79.84%
```
with order_counts as (
    select
        order_user_guid,
        count(order_guid) as order_count
    from stg_postgres_orders
    group by 1
),

final as (
    select
        count(
            case when order_count >= 2 then order_user_guid end
        ) as repeat_users,
    count(distinct order_user_guid) as total_users
from order_counts
)

select round((repeat_users/total_users)*100,2) as user_repeat_rate
from final;
```

**What are good indicators of a user who will likely purchase again? What about indicators of users who are likely NOT to purchase again?**
**If you had more data, what features would you want to look into to answer this question?**

Good indicators of a user who will likely purchase again include users who have made more than 1 purchase, how much inventory they have purchased, how much they have spent, and how much time they have spent browsing the website. Indicators of users NOT likely to purchase again would include users who have only made 1 non-recent purchase or users who have spent very little time on the website. I could also guess if their delivery took much longer than expected, it's somewhat likely they will not purchase again. If I had more data, I'd look into more specific user demographics (age, gender, income, etc.) as well as post-purchase information such as reviews and social media mentions.

**Explain the product mart models you added. Why did you organize the models in the way you did?**
I added a page view model to inform how many page views the sessions are getting as well as how long it's been since a users last session. I also added a product model to provide a more informative product table by joining  other tables with product information to it. Additionally, I added a user session model to better understand how different users are spending their time on the website. 


## Part 2. Tests
**What assumptions are you making about each model? (i.e. why are you adding each test?)**
I added a test to ensure the length of each phone number is exactly 12 strings, indicating a properly formatted and valid phone number.

**Your stakeholders at Greenery want to understand the state of the data each day. Explain how you would ensure these tests are passing regularly and how you would alert stakeholders about bad data getting through.**
To ensure tests are passing regularly, I'd set up a job to run daily and alert me and my team if any of the tests failed, and if so what the error message is so that we can assess the level of urgency. To alert stakeholders, I'd set up a related job that would provide steakholders with information about what tables are affected based on the test failures. Stakeholders could always seek more information if they needed, but at least the automated alert lets them know ASAP that there may be something wrong with their data.

## Part 3. dbt Snapshots
**Which products had their inventory change from week 1 to week 2?**
- Pothos
- Philodendron
- Monstera
- String of pearls


# Week 3 Questions

## Part 1
What is our overall conversion rate? **62.46%**
```
with session_counts as (
    select
        count(distinct event_session_checkout) as sessions_with_purchase,
        count(distinct event_session_guid) as total_sessions
    from fact_conversion_rate
)

select
    round((sessions_with_purchase / total_sessions) * 100, 2) as overall_conversion_rate
from session_counts;
```

What is our conversion rate by product?
```
with session_counts_product as (
    select
        product_name,
        count(distinct event_session_checkout) as sessions_with_purchase,
        count(distinct event_session_guid) as total_sessions
    from fact_conversion_rate
    where product_name is not null
    group by 1
)

select
    product_name,
    round((sessions_with_purchase / total_sessions) * 100, 2) as overall_conversion_rate
from session_counts_product
order by 2 desc;
```

| **Product Name** | **Overall Conversion Rate** |
|------------------| ----------------------------|
|String of pearls | 60.94 |
|Arrow Head       |	55.56 |
|Cactus           |	54.55 |
|ZZ Plant         |	53.97 |
|Bamboo           |	53.73 |
|Rubber Plant     |	51.85 |
|Monstera |	51.02 |
|Calathea Makoyana |	50.94 |
|Fiddle Leaf Fig |	50 |
|Majesty Palm |	49.25 |
|Aloe Vera |	49.23 |
|Devil's Ivy |	48.89 |
|Philodendron |	48.39 |
|Jade Plant |	47.83 |
|Pilea Peperomioides |	47.46 |
|Spider Plant |	47.46 |
|Dragon Tree |	46.77 |
|Money Tree |	46.43 |
|Orchid |	45.33 |
|Bird of Paradise |	45 |
|Ficus |	42.65 |
|Birds Nest Fern |	42.31 |
|Pink Anthurium |	41.89 |
|Boston Fern |	41.27 |
|Alocasia Polly |	41.18 |
|Peace Lily |	40.91 |
|Ponytail Palm |	40 |
|Snake Plant |	39.73 |
|Angel Wings Begonia |	39.34 |
|Pothos |	34.43 |

## Part 6
**Which products had their inventory change from Week 2 to Week 3?**
```
with latest_update as (
    select max(dbt_valid_from) as max_date
    from inventory_snapshot
    )

select distinct name
from inventory_snapshot
join latest_update on latest_update.max_date = inventory_snapshot.dbt_valid_from
where dbt_valid_to is null
and dbt_valid_from = max_date;
```
- Monstera
- Pothos
- Philodendron
- ZZ Plant
- String of pearls
- Bamboo


# Week 4 Questions
## Part 1. dbt Snapshots
**Which products had their inventory change from week 3 to week 4?**
```
with latest_week as (
    select max(dbt_valid_from) as max_date
    from inventory_snapshot
    )

select distinct
    name
from inventory_snapshot
join latest_week on latest_week.max_date = inventory_snapshot.dbt_valid_from
where dbt_valid_to is null
and dbt_valid_from = max_date;
``` 
- Monstera
- Pothos
- Philodendron
- ZZ Plant
- String of pearls
- Bamboo

**Now that we have 3 weeks of snapshot data, can you use the inventory changes to determine which products had the most fluctuations in inventory?**
```
with last_week_inventory as (
    select product_id, name, inventory as week_3_inventory
    from inventory_snapshot
    where dbt_updated_at = (select max(dbt_updated_at) from inventory_snapshot)
    ),

first_week_inventory as (
    select product_id, name, inventory as week_1_inventory
    from inventory_snapshot
    where dbt_updated_at = (select min(dbt_updated_at) from inventory_snapshot)
    )

select last_week_inventory.name, (week_1_inventory - week_3_inventory) as inventory_diff
from last_week_inventory
join first_week_inventory on first_week_inventory.product_id = last_week_inventory.product_id
order by 2 desc;
```
| **NAME** |	**INVENTORY_DIFF** |
 --- | --- |
| String of pearls |	58 |
| Pothos |	40 |
| Philodendron |	36 |
| ZZ Plant |	36 |
| Monstera |	27 |
| Bamboo |	12 |

**Did we have any items go out of stock in the last 3 weeks?**
```
select name
from inventory_snapshot
where inventory = 0;
``` 
- String of Pearls
- Pothos

## Part 2. Modeling Challenge
**How are our users moving through the product funnel? Which steps in the funnel have largest drop off points?**
```
select 
    sum(page_views) as page_views, 
    sum(add_to_carts) as add_to_carts, 
    sum(checkouts) as checkouts
from fact_product_funnel;
```
- Page View Sessions: 578
- Add to Cart Sessions: 467
- Checkout Sessions: 361

