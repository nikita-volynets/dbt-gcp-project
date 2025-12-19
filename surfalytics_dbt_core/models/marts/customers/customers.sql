with customer_base as (

    select * from {{ ref('stg_customers') }}

),

order_aggregates as (

    select * from {{ ref('int_customers__order_aggregates') }}

),

cohorts as (

    select * from {{ ref('int_customers__cohorts') }}

),

joined as (

    select
        customer_base.customer_id,
        customer_base.customer_name,

        -- Order behavior metrics
        order_aggregates.first_order_at,
        order_aggregates.most_recent_order_at,
        order_aggregates.total_orders,
        order_aggregates.total_revenue,
        order_aggregates.total_items_purchased,
        order_aggregates.avg_order_value,
        order_aggregates.avg_items_per_order,
        order_aggregates.customer_lifetime_days,

        -- Cohort assignment
        cohorts.cohort_month,
        cohorts.cohort_quarter,
        cohorts.cohort_year,

        -- Customer segmentation based on order behavior
        case
            when order_aggregates.total_orders >= 100
                or order_aggregates.total_revenue >= 10000
                then 'High Value'
            when order_aggregates.total_orders >= 20
                or order_aggregates.total_revenue >= 2000
                then 'Medium Value'
            else 'Low Value'
        end as customer_segment,

        -- Activity flags
        date_diff(
            current_date(),
            date(order_aggregates.most_recent_order_at),
            day
        ) <= 90 as is_active,

        date_diff(
            current_date(),
            date(order_aggregates.most_recent_order_at),
            day
        ) > 180 as is_churned

    from customer_base
    left join order_aggregates
        on customer_base.customer_id = order_aggregates.customer_id
    left join cohorts
        on customer_base.customer_id = cohorts.customer_id

)

select * from joined
