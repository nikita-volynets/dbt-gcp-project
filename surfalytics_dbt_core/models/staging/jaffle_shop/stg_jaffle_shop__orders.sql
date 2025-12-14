with source as (

    select * from {{ source('jaffle_shop', 'raw_orders') }}

),

renamed as (

    select
        id as order_id,
        customer as customer_id,
        store_id,
        cast(ordered_at as timestamp) as ordered_at,

        -- Convert monetary values from cents to dollars
        subtotal / 100.0 as subtotal,
        tax_paid / 100.0 as tax_paid,
        order_total / 100.0 as order_total,

        -- Calculate tax rate for validation
        case
            when subtotal > 0 then tax_paid / subtotal
            else 0
        end as tax_rate,

        current_timestamp() as _loaded_at

    from source

)

select * from renamed
