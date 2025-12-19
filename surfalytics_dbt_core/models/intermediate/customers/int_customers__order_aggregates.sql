with orders as (

    select * from {{ ref('int_orders__joined') }}

),

order_items as (

    select
        order_id,
        count(*) as items_in_order
    from {{ ref('stg_order_items') }}
    group by order_id

),

customer_aggregates as (

    select
        orders.customer_id,

        -- Order timing
        min(orders.ordered_at) as first_order_at,
        max(orders.ordered_at) as most_recent_order_at,

        -- Order counts and totals
        count(distinct orders.order_id) as total_orders,
        sum(orders.order_total) as total_revenue,
        sum(order_items.items_in_order) as total_items_purchased,

        -- Averages
        avg(orders.order_total) as avg_order_value,
        avg(order_items.items_in_order) as avg_items_per_order,

        -- Customer lifetime
        date_diff(
            date(max(orders.ordered_at)),
            date(min(orders.ordered_at)),
            day
        ) as customer_lifetime_days

    from orders
    left join order_items on orders.order_id = order_items.order_id
    group by orders.customer_id

)

select * from customer_aggregates
