# Surfalytics dbt Core - Project Context

## Project Overview

**Surfalytics dbt Core** is a production-ready dbt project designed to demonstrate best practices in analytics engineering. It transforms raw e-commerce data (based on the "Jaffle Shop" dataset) into analytics-ready models using Google BigQuery as the data warehouse.

The project follows the **Medallion Architecture**:
1.  **Staging Layer (`stg_`):** Light transformations, cleaning, and standardization of raw data. Materialized as views.
2.  **Intermediate Layer (`int_`):** Complex business logic, joins, and aggregations. Materialized as views or tables.
3.  **Marts Layer:** Business-facing entities and facts optimized for reporting. Materialized as tables or incremental models.

## Architecture & Structure

The project is rooted in the `surfalytics_dbt_core` directory.

### Directory Structure

-   **`models/`**: Contains the SQL transformation logic.
    -   `staging/`: Source-aligned transformations (e.g., `stg_customers.sql`).
    -   `intermediate/`: Domain-specific logic (e.g., `int_orders__joined.sql`).
    -   `marts/`: Final consumption tables (e.g., `customers.sql`, `order_items.sql`).
-   **`seeds/`**: CSV files containing raw data (e.g., `raw_customers.csv`).
-   **`tests/`**: Custom data quality tests (generic tests are defined in `.yml` files).
-   **`macros/`**: Reusable SQL snippets (e.g., `generate_schema_name.sql`).
-   **`analyses/`**: Ad-hoc analytical queries.
-   **`snapshots/`**: Type 2 Slowly Changing Dimensions (SCD).

### Key Technologies

-   **dbt Core:** Data transformation and modeling.
-   **Google BigQuery:** Cloud data warehouse.
-   **SQLFluff:** SQL linting and formatting.
-   **Pre-commit:** Automated checks for code quality.

## Development Conventions

### SQL Style (enforced by SQLFluff)
-   **Dialect:** BigQuery
-   **Indentation:** 4 spaces
-   **Casing:** Lowercase for keywords, functions, and data types.
-   **Trailing Commas:** Enforced/Allowed (check specific rules).
-   **Structure:** CTEs (Common Table Expressions) are preferred for readability.

### Naming Conventions
-   **Staging:** `stg_<source>__<table_name>` (e.g., `stg_jaffle_shop__customers`)
-   **Intermediate:** `int_<domain>__<concept>` (e.g., `int_orders__joined`)
-   **Marts:** `<concept>` (e.g., `customers`, `monthly_revenue`)
-   **Sources:** Defined in `_sources.yml` files.

### Testing
-   **Schema Tests:** Defined in `.yml` files (unique, not_null, relationships, accepted_values).
-   **Custom Tests:** SQL files in the `tests/` directory.
-   **Expectation:** 100% test coverage for marts and critical intermediate models.

## Building and Running

All dbt commands should be run from the `surfalytics_dbt_core` directory.

### Prerequisites
-   dbt Core installed (`pip install dbt-bigquery`)
-   GCP credentials configured (e.g., `gcloud auth application-default login`)
-   `profiles.yml` configured (or env vars set)

### Common Commands

```bash
# Change to the project directory
cd surfalytics_dbt_core

# Install dependencies
dbt deps

# Load seed data (CSV to BigQuery)
dbt seed

# Run all models
dbt run

# Run only specific models (and their parents)
dbt run --select customers+

# Run data quality tests
dbt test

# Build (Run + Test) - Recommended for CI
dbt build

# Generate and view documentation
dbt docs generate
dbt docs serve
```

### Code Quality Checks

```bash
# Run pre-commit hooks (linting, formatting, yaml checks)
pre-commit run --all-files

# Lint SQL files specifically
sqlfluff lint models/
```

## Configuration Files
-   **`dbt_project.yml`:** Main dbt configuration (paths, materializations).
-   **`.sqlfluff`:** SQL linting rules.
-   **`.pre-commit-config.yaml`:** Pre-commit hook definitions.
-   **`packages.yml`:** dbt package dependencies.
