-- dim_promos_lookup.sql

with 

int_promos as (

    select * from {{ ref('int_promos_live_dates_added' )}}

),

dim_promos as (

    select
        -- ids
        promo_code

        -- strings
        , promo_status

        -- dates
        , promo_launch_date
        , promo_last_used_date

        -- numeric
        , promo_discount_dollars 
        
    from int_promos

)

select * from dim_promos