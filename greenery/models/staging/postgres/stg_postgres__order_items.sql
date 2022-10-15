-- stg_postgres__order_items.sql


with order_items_source as (

    select * from {{ source('postgres', 'order_items') }}

),

standardized as (

    select
        -- guids
        {{ dbt_utils.surrogate_key(['order_id', 'product_id']) }} as order_product_guid
        , order_id as order_guid
        , product_id as product_guid
        
        -- numeric
        , quantity as product_quanity

    from order_items_source

)

select * from standardized