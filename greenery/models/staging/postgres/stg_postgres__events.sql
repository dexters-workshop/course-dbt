-- stg_postgres__events.sql


with event_source as (

    select * from {{ source('postgres', 'events') }}

),

standardized as (

    select
        -- guids
        event_id     as event_guid
        , session_id as session_guid
        , user_id    as user_guid
        , order_id   as order_guid
        , product_id as product_guid

        -- strings
        , page_url 
        , event_type

        -- timestamps
        , created_at as created_at_utc

    from event_source

)

select * from standardized