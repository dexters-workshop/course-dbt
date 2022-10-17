-- int_promos_dates_added.sql


with 

promos as (

    select * from {{ ref('stg_postgres__promos' )}}

),

orders as (

    select * from {{ ref('stg_postgres__orders' )}}

),

promotional_dates_retrieved as (

    select
        promo_code
        , date(min(created_at_utc)) as promo_launch_date
        , date(max(created_at_utc)) as promo_last_used_date
    from orders
    where promo_code is not null
    group by 1

),

promo_lookup_table as (

    select
        -- ids
        promos.promo_code

        -- strings
        , promo_status

        -- dates
        , promo_launch_date
        , promo_last_used_date

        -- numeric
        , promo_discount_dollars 
    from promos
    join promotional_dates_retrieved
        on promos.promo_code = promotional_dates_retrieved.promo_code

)

select * from promo_lookup_table