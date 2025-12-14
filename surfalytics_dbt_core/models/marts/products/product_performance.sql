with order_items as (

    select * from {{ ref('order_items') }}

),

products as (

    select * from {{ ref('products') }}

),

product_sales as (

    select
        order_items.sku,

        -- Sales metrics
        count(*) as total_items_sold,
        sum(order_items.item_revenue) as total_revenue,
        count(distinct order_items.order_id) as num_orders_containing_product,
        count(*) / count(distinct order_items.order_id) as avg_items_per_order,

        -- Timing
        min(order_items.ordered_at) as first_sale_at,
        max(order_items.ordered_at) as most_recent_sale_at

    from order_items
    group by order_items.sku

),

final as (

    select
        products.sku,
        products.product_name,
        products.product_type,
        products.price,
        products.total_supply_cost,
        products.gross_margin,

        -- Sales performance
        product_sales.total_items_sold,
        product_sales.total_revenue,
        product_sales.num_orders_containing_product,
        product_sales.avg_items_per_order,
        product_sales.first_sale_at,
        product_sales.most_recent_sale_at,

        -- Profitability
        product_sales.total_items_sold * products.total_supply_cost as total_cost,
        product_sales.total_revenue - (product_sales.total_items_sold * products.total_supply_cost) as total_profit,

        -- Ranking
        row_number() over (order by product_sales.total_revenue desc) as revenue_rank

    from products
    left join product_sales
        on products.sku = product_sales.sku

)

select * from final
order by revenue_rank
