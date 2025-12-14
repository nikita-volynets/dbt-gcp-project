with customer_aggregates as (

    select * from {{ ref('int_customers__order_aggregates') }}

),

cohorts as (

    select
        customer_id,

        -- Extract cohort dimensions from first order date
        date_trunc(date(first_order_at), month) as cohort_month,
        date_trunc(date(first_order_at), quarter) as cohort_quarter,
        extract(year from first_order_at) as cohort_year

    from customer_aggregates

)

select * from cohorts
