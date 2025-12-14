with customers as (

    select * from {{ ref('customers') }}

),

-- Only include customers with 2+ orders for meaningful lifetime metrics
repeat_customers as (

    select
        customer_id,
        customer_name,
        total_orders,
        total_revenue as ltv,
        customer_lifetime_days,

        -- Calculate average days between orders
        case
            when total_orders > 1
                then customer_lifetime_days / (total_orders - 1)
            else null
        end as avg_days_between_orders,

        -- Simple LTV projection for next 12 months
        case
            when total_orders > 1 and customer_lifetime_days > 0
                then (total_revenue / customer_lifetime_days) * 365
            else null
        end as predicted_ltv_12mo,

        first_order_at,
        most_recent_order_at,
        customer_segment

    from customers
    where total_orders >= 2

)

select * from repeat_customers
order by ltv desc
