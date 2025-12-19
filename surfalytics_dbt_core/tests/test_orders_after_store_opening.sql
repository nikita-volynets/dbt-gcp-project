-- Test: Validate that no orders occur before their associated store opened
-- Description: This test ensures data integrity by checking that all orders
-- have an ordered_at timestamp that is on or after the store's opened_at timestamp.
--
-- Business Rule: A store cannot process orders before it has opened for business.
--
-- Returns: Any orders that violate this temporal constraint, with details
-- about the order, store, and time difference for debugging.

with orders as (
    select
        order_id,
        store_id,
        ordered_at
    from {{ ref('stg_orders') }}
),

stores as (
    select
        store_id,
        store_name,
        opened_at
    from {{ ref('stg_stores') }}
),

validation_errors as (
    select
        orders.order_id,
        orders.store_id,
        stores.store_name,
        orders.ordered_at,
        stores.opened_at as store_opened_at,
        timestamp_diff(orders.ordered_at, stores.opened_at, day) as days_difference
    from orders
    inner join stores
        on orders.store_id = stores.store_id
    where orders.ordered_at < stores.opened_at
)

select * from validation_errors
