with orders as (

    select * from {{ ref('int_orders__joined') }}

),

cohorts as (

    select * from {{ ref('int_customers__cohorts') }}

),

cohort_data as (

    select
        cohorts.cohort_month,
        orders.customer_id,
        date_trunc(date(orders.ordered_at), month) as order_month,

        -- Calculate months since first order
        date_diff(
            date_trunc(date(orders.ordered_at), month),
            cohorts.cohort_month,
            month
        ) as months_since_first_order,

        orders.order_total

    from orders
    inner join cohorts
        on orders.customer_id = cohorts.customer_id

),

cohort_size as (

    select
        cohort_month,
        count(distinct customer_id) as cohort_size
    from cohort_data
    where months_since_first_order = 0
    group by cohort_month

),

cohort_metrics as (

    select
        cohort_data.cohort_month,
        cohort_data.months_since_first_order,

        -- Customer retention
        count(distinct cohort_data.customer_id) as customers_in_period,

        -- Activity metrics
        count(distinct cohort_data.customer_id) as orders_in_period,
        sum(cohort_data.order_total) as revenue_in_period

    from cohort_data
    group by
        cohort_data.cohort_month,
        cohort_data.months_since_first_order

),

final as (

    select
        cohort_metrics.cohort_month,
        cohort_metrics.months_since_first_order,
        cohort_size.cohort_size,
        cohort_metrics.customers_in_period,
        cohort_metrics.orders_in_period,
        cohort_metrics.revenue_in_period,

        -- Calculate retention rate
        cohort_metrics.customers_in_period / cohort_size.cohort_size as retention_rate

    from cohort_metrics
    left join cohort_size
        on cohort_metrics.cohort_month = cohort_size.cohort_month

)

select * from final
order by cohort_month, months_since_first_order
