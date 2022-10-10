-- stg_postgres__order_items.sql


with order_items_source as (

    select * from {{ source('postgres', 'order_items') }}

),

staged as (

    select
        -- guids
        order_id as order_guid
        , product_id as product_guid
        
        -- numeric
        , quantity as product_quanity

    from order_items_source

)

select * from staged