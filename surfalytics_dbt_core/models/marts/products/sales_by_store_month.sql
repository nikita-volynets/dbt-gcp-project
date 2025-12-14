with orders as (

    select * from {{ ref('int_orders__joined') }}

),

monthly_sales as (

    select
        store_id,
        store_name,
        order_month,

        -- Aggregate metrics
        count(distinct order_id) as total_orders,
        sum(order_total) as total_revenue,
        sum(tax_paid) as total_tax_collected,
        avg(order_total) as avg_order_value,

        -- Store context
        min(store_opened_at) as store_opened_at,
        date_diff(
            last_day(order_month),
            date(min(store_opened_at)),
            day
        ) as days_store_open_at_month_end

    from orders
    group by
        store_id,
        store_name,
        order_month

),

with_comparisons as (

    select
        store_id,
        store_name,
        order_month,
        total_orders,
        total_revenue,
        total_tax_collected,
        avg_order_value,
        store_opened_at,
        days_store_open_at_month_end,

        -- Running totals
        sum(total_revenue) over (
            partition by store_id
            order by order_month
            rows between unbounded preceding and current row
        ) as cumulative_revenue,

        -- Month-over-month comparison
        lag(total_revenue) over (
            partition by store_id
            order by order_month
        ) as prev_month_revenue,

        -- Year-over-year comparison
        lag(total_revenue, 12) over (
            partition by store_id
            order by order_month
        ) as yoy_revenue

    from monthly_sales

),

final as (

    select
        *,

        -- Growth calculations
        case
            when prev_month_revenue > 0
                then (total_revenue - prev_month_revenue) / prev_month_revenue
            else null
        end as mom_growth_rate,

        case
            when yoy_revenue > 0
                then (total_revenue - yoy_revenue) / yoy_revenue
            else null
        end as yoy_growth_rate

    from with_comparisons

)

select * from final
order by store_name, order_month
