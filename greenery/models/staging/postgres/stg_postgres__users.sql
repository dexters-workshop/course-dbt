-- stg_postgres__users.sql

with

users_source as (

    select * from {{ source('postgres','users') }}

),

standardized as (

    select
        -- ids
        user_id    as user_guid,
        address_id as user_address_guid,

        -- strings
        first_name as user_first_name,
        last_name as user_last_name,
        email as user_email,
        phone_number as user_phone_number,

        -- timestamps
        created_at as created_at_utz,
        updated_at as udpated_at_utz

    from users_source

)

select * from standardized