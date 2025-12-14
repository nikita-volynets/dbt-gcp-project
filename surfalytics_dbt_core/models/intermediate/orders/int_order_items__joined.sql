with order_items as (

    select * from {{ ref('stg_jaffle_shop__order_items') }}

),

products as (

    select * from {{ ref('stg_jaffle_shop__products') }}

),

orders as (

    select * from {{ ref('stg_jaffle_shop__orders') }}

),

joined as (

    select
        order_items.order_item_id,
        order_items.order_id,
        order_items.sku,

        -- Product attributes
        products.product_name,
        products.type as product_type,
        products.price,

        -- Order context
        orders.customer_id,
        orders.store_id,
        orders.ordered_at,

        -- Calculated revenue per item
        products.price as item_revenue

    from order_items
    left join products on order_items.sku = products.sku
    left join orders on order_items.order_id = orders.order_id

)

select * from joined
