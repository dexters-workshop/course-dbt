-- int_users_joined_with_user_details.sql

with

users as (

    select * from {{ ref('stg_postgres__users')}}

),

user_addresses as (

    select * from {{ ref('stg_postgres__user_addresses')}}
),

users_and_user_details_joined as (

    select
        users.user_guid
        , users.user_address_guid
        , users.user_first_name
        , users.user_last_name
        , users.user_email
        , users.user_phone_number
        , user_addresses.user_country
        , user_addresses.user_address
        , user_addresses.user_state
        , user_addresses.user_zipcode
        , users.created_at_utz
        , users.udpated_at_utz

    from users
    join user_addresses using(user_address_guid)

)

select * from users_and_user_details_joined


