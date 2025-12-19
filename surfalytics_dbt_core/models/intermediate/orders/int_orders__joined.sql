with orders as (

    select * from {{ ref('stg_orders') }}

),

stores as (

    select * from {{ ref('stg_stores') }}

),

customers as (

    select * from {{ ref('stg_customers') }}

),

joined as (

    select
        orders.order_id,
        orders.customer_id,
        orders.store_id,
        orders.ordered_at,
        orders.subtotal,
        orders.tax_paid,
        orders.order_total,

        -- Store attributes
        stores.store_name,
        stores.tax_rate as store_tax_rate,
        stores.opened_at as store_opened_at,

        -- Customer attributes
        customers.customer_name,

        -- Calculated fields
        date_diff(date(orders.ordered_at), date(stores.opened_at), day) as days_since_store_opened,

        -- Identify first orders using window function
        row_number() over (
            partition by orders.customer_id
            order by orders.ordered_at
        ) = 1 as is_first_order,

        -- Date parts for aggregation
        date(orders.ordered_at) as order_date,
        date_trunc(date(orders.ordered_at), month) as order_month,
        date_trunc(date(orders.ordered_at), quarter) as order_quarter,
        extract(year from orders.ordered_at) as order_year

    from orders
    left join stores on orders.store_id = stores.store_id
    left join customers on orders.customer_id = customers.customer_id

)

select * from joined
