-- dim_users.sql


with

intermediate_users_table as (

    select * from {{ ref('int_users_joined_with_user_details') }}

),

dim_users as (

    select
        user_guid
        , user_address_guid
        , user_first_name
        , user_last_name
        , user_email
        , user_phone_number
        , user_country
        , user_address
        , user_state
        , user_zipcode
        , created_at_utz
        , udpated_at_utz
    from intermediate_users_table

)

select * from dim_users