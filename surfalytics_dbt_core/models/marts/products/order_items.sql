{{
    config(
        materialized='incremental',
        unique_key='order_item_id',
        on_schema_change='fail'
    )
}}

with order_items as (

    select * from {{ ref('int_order_items__joined') }}

    {% if is_incremental() %}
        -- Only load new records
        where ordered_at > (select max(ordered_at) from {{ this }})
    {% endif %}

),

products as (

    select * from {{ ref('products') }}

),

final as (

    select
        order_items.order_item_id,
        order_items.order_id,
        order_items.sku,
        order_items.customer_id,
        order_items.store_id,

        -- Timestamps and date dimensions
        order_items.ordered_at,
        date(order_items.ordered_at) as order_date,
        date_trunc(date(order_items.ordered_at), month) as order_month,
        date_trunc(date(order_items.ordered_at), quarter) as order_quarter,
        extract(year from order_items.ordered_at) as order_year,

        -- Product attributes (from latest product mart)
        products.product_name,
        products.product_type,
        products.price,
        products.total_supply_cost,
        products.gross_margin,

        -- Revenue and profit
        order_items.item_revenue,
        products.gross_profit_per_unit as item_profit,

        -- Product type flags
        products.product_type = 'Jaffle' as is_jaffle,
        products.product_type = 'Beverage' as is_beverage

    from order_items
    left join products
        on order_items.sku = products.sku

)

select * from final
