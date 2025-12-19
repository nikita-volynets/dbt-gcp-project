with product_catalog as (

    select * from {{ ref('stg_products') }}

),

supply_costs as (

    select * from {{ ref('int_products__supply_costs') }}

),

final as (

    select
        product_catalog.sku,
        product_catalog.product_name,
        product_catalog.type as product_type,
        product_catalog.price,
        product_catalog.description,

        -- Supply cost structure
        supply_costs.total_supply_cost,
        supply_costs.perishable_cost,
        supply_costs.non_perishable_cost,
        supply_costs.num_supplies,
        supply_costs.num_perishable_supplies,
        supply_costs.num_non_perishable_supplies,

        -- Profitability metrics
        (product_catalog.price - supply_costs.total_supply_cost) / product_catalog.price
            as gross_margin,

        (product_catalog.price - supply_costs.total_supply_cost) / supply_costs.total_supply_cost
            as markup_percentage,

        product_catalog.price - supply_costs.total_supply_cost as gross_profit_per_unit

    from product_catalog
    left join supply_costs
        on product_catalog.sku = supply_costs.sku

)

select * from final
