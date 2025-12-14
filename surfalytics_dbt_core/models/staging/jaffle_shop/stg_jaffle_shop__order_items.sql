with source as (

    select * from {{ source('jaffle_shop', 'raw_items') }}

),

renamed as (

    select
        id as order_item_id,
        order_id,
        sku,
        current_timestamp() as _loaded_at

    from source

)

select * from renamed
