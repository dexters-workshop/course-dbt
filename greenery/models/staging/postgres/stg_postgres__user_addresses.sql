-- stg_postgres__user_addresses.sql

with user_addresses_source as (

    select * from {{ source('postgres', 'addresses') }}

),

staged as (

    select
        -- ids
        address_id as user_address_guid

        -- strings
        , address  as user_address
        , state    as user_state
        , country  as user_country
        , lpad(zipcode::varchar(5), 5, '0') as user_zipcode  -- change to varchar to left-pad zipcodes with 0's e.g., 2203 -> '02203'

    from user_addresses_source

)

select * from staged