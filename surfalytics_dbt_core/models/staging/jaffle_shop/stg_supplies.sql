with source as (

    select * from {{ source('jaffle_shop', 'raw_supplies') }}

),

renamed as (

    select
        id as supply_id,
        name as supply_name,

        -- Convert cost from cents to dollars
        cost / 100.0 as cost,

        cast(perishable as boolean) as perishable,
        sku,
        current_timestamp() as _loaded_at

    from source

)

select * from renamed
