-- dim_products.sql


with staged_products as (

    select * from {{ ref('stg_postgres__products') }}
  
),

products as (

    select
        product_guid
        , product_name
        , product_price
        , product_inventory

    from staged_products

)

select * from products