{% test column_sum_equals(model,
                          column_1,
                          column_2,
                          sum_column,
                          tolerance=0.01) %}
{#
  Test to validate that two numeric columns sum to equal a third column.

  Parameters:
    - model: The model being tested (automatically passed)
    - column_1: First addend column name
    - column_2: Second addend column name
    - sum_column: Expected sum column name
    - tolerance: Maximum acceptable difference (default: 0.01)

  Example usage in schema.yml:
    data_tests:
      - column_sum_equals:
          column_1: subtotal
          column_2: tax_paid
          sum_column: order_total
          tolerance: 0.01

  Returns:
    Rows where the difference between calculated sum and expected sum
    exceeds the tolerance threshold.
#}

with validation as (
    select
        {{ column_1 }},
        {{ column_2 }},
        {{ sum_column }},
        {{ column_1 }} + {{ column_2 }} as calculated_sum,
        abs(({{ column_1 }} + {{ column_2 }}) - {{ sum_column }}) as difference
    from {{ model }}
    where
        -- Exclude rows with NULL values to avoid NULL arithmetic
        {{ column_1 }} is not null
        and {{ column_2 }} is not null
        and {{ sum_column }} is not null
),

validation_errors as (
    select *
    from validation
    where difference > {{ tolerance }}
)

select * from validation_errors

{% endtest %}
