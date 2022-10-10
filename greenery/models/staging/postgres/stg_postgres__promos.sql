-- stg_postgres__promos.sql


with promos_source as (

    select * from {{ source('postgres', 'promos') }}

),

staged as (

    select
        -- ids
        promo_id as promo_code

        -- strings
        , status as promo_status

        -- numeric
        , discount as promo_discount_dollars

    from promos_source

)

select * from staged

