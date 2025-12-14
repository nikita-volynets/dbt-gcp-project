with supplies as (

    select * from {{ ref('stg_jaffle_shop__supplies') }}

),

aggregated as (

    select
        sku,

        -- Total supply costs
        sum(cost) as total_supply_cost,

        -- Split by perishable status
        sum(case when perishable then cost else 0 end) as perishable_cost,
        sum(case when not perishable then cost else 0 end) as non_perishable_cost,

        -- Supply counts
        count(*) as num_supplies,
        sum(case when perishable then 1 else 0 end) as num_perishable_supplies,
        sum(case when not perishable then 1 else 0 end) as num_non_perishable_supplies

    from supplies
    group by sku

)

select * from aggregated
