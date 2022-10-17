-- stg_postgres__orders.sql


with orders_source as (

    select * from {{ source('postgres', 'orders') }}

),

standardized as (

    select
        -- guids/ids
        order_id as order_guid
        , user_id as user_guid
        , tracking_id as tracking_guid
        , address_id as address_guid
        , promo_id as promo_code

        -- timestamps
        , created_at as created_at_utc
        , estimated_delivery_at as estimated_delivery_at_utc 
        , delivered_at as delivered_at_utc

        -- strings
        , shipping_service
        , status

        -- numeric
        , order_cost
        , shipping_cost
        , order_total

    from orders_source

)

select * from standardized