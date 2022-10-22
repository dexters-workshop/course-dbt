## Week 01 Project


**Answer these questions using the data available using SQL queries.** 
-- You should query the dbt generated (staging) tables you have just created.

1. How many users do we have? **130 users**

    ```sql
    select count(user_guid) as user_count
    from stg_postgres__users
    ```

2. On average, how many orders do we receive per hour? **~7.5 orders per hour**

    ```sql
    -- cte
    with orders_per_hour as(

        -- count number of orders per hour
        select
            date_trunc('hour', created_at_utc) as order_hour
            , count(order_guid) as order_count
        from stg_postgres__orders
        group by 1
    )

    -- get average
    select round(avg(order_count), 1) as avg_orders_per_hour
    from orders_per_hour
    ```

3. On average, how long does an order take from being placed to being delivered? **~93.4 hours**

    ```sql
    -- cte
    with hours_til_delivery as (
        
        -- get time between order created to order delivered 
                        created_at_utc, 
        select datediff('hours', 
                        delivered_at_utc) as hours_to_delivery
        from stg_postgres__orders
    )
        where status = 'delivered'

    -- get average
    select round(avg(hours_to_delivery), 1) as avg_hours_to_deliver
    from hours_til_delivery
    ```

4. How many users have only made one purchase? Two purchases? Three+ purchases?
- Note: you should consider a purchase to be a single order. In other words, if a user places one order for 3 products, they are considered to have made 1 purchase.
    - 1 purchase: **25**
    - 2 purchases:  **28**
    - 3 or more purchases: **71**

    ```sql
    -- cte
    with order_freq_by_user as (
        
        -- count orders by user
        select
            user_guid
            , count(order_guid) as order_freq
        from stg_postgres__orders
        group by 1
    ),

    user_order_segmentation as (

        -- classify users based on order frequency
        select
            user_guid
            , case
                when order_freq  = 1 then '1'
                when order_freq  = 2 then '2'
                when order_freq >= 3 then '3+'
                else null
            end as order_frequency
        from order_freq_by_user
    )

    -- count freq types
    select 
        order_frequency
        , count(user_guid) as freq_type_count
    from user_order_segmentation
    group by 1
    ```

5. On average, how many unique sessions do we have per hour?
    - to accurately calculate these metrics i got the min(created_at) first to avoid sessions that had events that crossed over from one hour to the next (that'd muddy things up).
    - **mean of 11.8 and median of 7 sessions per hour**
        -  high volume hours were skewing 'some' hours so that'd be interesting to dive into. maybe a promotion was running? the median is more than likely more representative in this case

    ```sql
    -- cte
    with distinct_sessions as (

        -- get hour of first event in session
        select
            session_guid
            , min(date_trunc('hour', created_at_utc)) as session_hour
        from stg_postgres__events
        group by 1
    ),


    sessions_per_hour as (
        
        -- count total sessions per hour
        select
            session_hour
            , count(session_guid) total_sessions
        from distinct_sessions
        group by 1
    )

    -- calculate mean/median number of sessions per hour
    select 
        avg(total_sessions) as mean_num_sessions_per_hour, 
        median(total_sessions) as median_num_sessions_per_hour
    from sessions_per_hour
    ```