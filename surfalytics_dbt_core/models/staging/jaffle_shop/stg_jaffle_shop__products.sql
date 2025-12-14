with source as (

    select * from {{ source('jaffle_shop', 'raw_products') }}

),

renamed as (

    select
        sku,
        name as product_name,

        -- Standardize product type to title case
        initcap(type) as type,

        -- Convert price from cents to dollars
        price / 100.0 as price,

        description,
        current_timestamp() as _loaded_at

    from source

)

select * from renamed
