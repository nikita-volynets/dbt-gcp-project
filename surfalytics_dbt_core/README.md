# Surfalytics dbt Core

> **A production-ready dbt project demonstrating medallion architecture best practices for the data community**

[![dbt Core](https://img.shields.io/badge/dbt-Core-FF694B?logo=dbt)](https://www.getdbt.com/)
[![BigQuery](https://img.shields.io/badge/BigQuery-Google%20Cloud-4285F4?logo=google-cloud)](https://cloud.google.com/bigquery)
[![Architecture](https://img.shields.io/badge/Architecture-Medallion-gold)]()
[![Tests](https://img.shields.io/badge/Tests-109%20passing-success)]()

---

## 📖 About This Project

This project is a **teaching example** of how to implement a clean, maintainable medallion architecture using dbt Core and BigQuery. It transforms raw e-commerce data (Jaffle Shop dataset) into analytics-ready models that power customer segmentation, cohort analysis, and product profitability insights.

**What makes this different?** Rather than just showing *what* to build, this project explains *why* architectural decisions were made, making it ideal for data practitioners learning dbt best practices.

**Key Highlights:**
- 🏗️ Clean 3-layer medallion architecture (staging → intermediate → marts)
- ✅ 109 passing tests ensuring data quality (100% test coverage)
- 📊 Real analytics: customer LTV, cohort retention, product profitability
- 📚 Comprehensive documentation at model and column level
- 🎯 Production-ready patterns: incremental models, strategic materialization

---

## 🏛️ Architecture Overview

This project follows the **medallion architecture** pattern, organizing data into three progressive layers of refinement:

```
┌─────────────────────────────────────────────────────────────┐
│                      RAW DATA (Seeds)                       │
│              6 CSV files → raw_jaffle_shop dataset          │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                   STAGING LAYER (6 models)                  │
│  • Light transformations (renaming, type casting)           │
│  • One model per source table                               │
│  • Materialized as VIEWS for freshness                      │
│  • Schema: staging                                          │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                 INTERMEDIATE LAYER (5 models)               │
│  • Business logic, joins, aggregations                      │
│  • Reusable building blocks                                 │
│  • Organized by domain (orders, customers, products)        │
│  • Materialized as VIEWS + selective TABLES                 │
│  • Schema: intermediate                                     │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                    MARTS LAYER (7 models)                   │
│  • Analytics-ready dimension and fact tables                │
│  • Optimized for BI tool consumption                        │
│  • Customer Analytics + Product/Sales Analytics             │
│  • Materialized as TABLES + INCREMENTAL                     │
│  • Schemas: customers, products                             │
└─────────────────────────────────────────────────────────────┘
```

**Why this structure?**
- **Staging**: Establishes a clean, standardized foundation (single source of truth)
- **Intermediate**: Prevents duplicated logic and enables reusable components
- **Marts**: Delivers business-friendly tables optimized for analytics performance

---

## 📊 Analytics Capabilities

### Customer Analytics

**Customer Dimension (`customers`)**
- Customer segmentation (High/Medium/Low Value based on orders and revenue)
- Activity tracking (active = ordered in last 90 days, churned = 180+ days inactive)
- Cohort assignment by first order month/quarter/year
- Lifetime metrics: total orders, revenue, avg order value

**Cohort Retention Analysis (`customer_retention_cohorts`)**
- Month-by-month retention rates for each customer cohort
- Track customer behavior over their lifetime
- Identify when customers typically churn
- Measure cohort performance over time

**Customer Lifetime Value (`customer_ltv`)**
- Realized LTV for all repeat customers
- Average days between orders
- 12-month projected LTV based on historical patterns
- Segmentation overlay for value targeting

### Product & Sales Analytics

**Product Dimension (`products`)**
- Complete product catalog with cost structure
- Gross margin and markup percentage calculations
- Supply cost breakdown (perishable vs non-perishable)
- Profitability metrics per product

**Sales Fact Table (`order_items`)** - Incremental
- Item-level transaction detail
- Time dimensions for trending (date, month, quarter, year)
- Profitability per item (revenue and profit)
- Product type flags for category analysis

**Product Performance (`product_performance`)**
- Sales rankings by revenue
- Total items sold and orders containing each product
- First and most recent sale dates
- Total profit calculations

**Store Performance (`sales_by_store_month`)**
- Monthly sales aggregations by store location
- Growth metrics: month-over-month and year-over-year
- Cumulative revenue tracking
- Average order value trends

---

## 📁 Project Structure

```
surfalytics_dbt_core/
├── models/
│   ├── staging/
│   │   └── jaffle_shop/
│   │       ├── _jaffle_shop__sources.yml       # Source definitions
│   │       ├── _jaffle_shop__models.yml        # Tests & documentation
│   │       ├── stg_jaffle_shop__customers.sql
│   │       ├── stg_jaffle_shop__orders.sql
│   │       ├── stg_jaffle_shop__order_items.sql
│   │       ├── stg_jaffle_shop__products.sql
│   │       ├── stg_jaffle_shop__stores.sql
│   │       └── stg_jaffle_shop__supplies.sql
│   │
│   ├── intermediate/
│   │   ├── orders/
│   │   │   ├── int_orders__joined.sql          # Enriched order facts
│   │   │   └── int_order_items__joined.sql
│   │   ├── customers/
│   │   │   ├── int_customers__order_aggregates.sql
│   │   │   └── int_customers__cohorts.sql
│   │   └── products/
│   │       └── int_products__supply_costs.sql
│   │
│   └── marts/
│       ├── customers/
│       │   ├── customers.sql                    # Customer dimension
│       │   ├── customer_retention_cohorts.sql
│       │   └── customer_ltv.sql
│       └── products/
│           ├── products.sql                     # Product dimension
│           ├── order_items.sql                  # Fact table (incremental)
│           ├── product_performance.sql
│           └── sales_by_store_month.sql
│
├── seeds/
│   ├── raw_customers.csv                        # 935 customers
│   ├── raw_orders.csv                           # 61,948 orders
│   ├── raw_items.csv                            # 90,900 line items
│   ├── raw_products.csv                         # 10 products
│   ├── raw_stores.csv                           # 6 store locations
│   └── raw_supplies.csv                         # 65 supply items
│
├── macros/
│   └── generate_schema_name.sql                 # Custom schema naming
│
├── dbt_project.yml                              # Project configuration
├── profiles.yml                                 # BigQuery connection
└── README.md                                    # This file
```

---

## 🎓 Layer-by-Layer Breakdown

### Staging Layer (6 models)

**What it does:** Light transformations on raw data - renaming columns, type casting, standardization.

**Why it matters:** Creates a clean, reliable foundation. All downstream models reference staging, not raw sources, ensuring consistency.

**Example models:**
- `stg_jaffle_shop__orders`: Converts monetary amounts from cents to dollars, renames columns to standard names
- `stg_jaffle_shop__products`: Standardizes product types to title case, converts pricing
- `stg_jaffle_shop__customers`: Simplest transformation - just clean column names

**Materialization:** Views (keeps data fresh, minimal storage)

### Intermediate Layer (5 models)

**What it does:** Implements business logic, joins tables, creates reusable building blocks.

**Why it matters:** Prevents logic duplication. When you need enriched order data, you reference `int_orders__joined` rather than rebuilding joins everywhere.

**Key models by domain:**

**Orders:**
- `int_orders__joined`: Joins orders with customers and stores, adds date dimensions, identifies first orders using window functions
- `int_order_items__joined`: Enriches line items with product details and order context

**Customers:**
- `int_customers__order_aggregates`: Aggregates customer behavior (total orders, revenue, first/last order dates)
- `int_customers__cohorts`: Assigns cohort dimensions based on first order

**Products:**
- `int_products__supply_costs`: Sums up bill of materials costs per product

**Materialization:** Views for lightweight models, Tables for performance-critical aggregates (orders, customer aggregates)

### Marts Layer (7 models)

**What it does:** Delivers analytics-ready tables optimized for BI tools and reporting.

**Why it matters:** Business users query these tables directly - they're designed for performance and usability.

**Customer Analytics Mart:**
- `customers`: Primary customer dimension with segmentation logic
- `customer_retention_cohorts`: Pre-calculated retention metrics by cohort
- `customer_ltv`: Lifetime value analysis for repeat customers

**Product/Sales Analytics Mart:**
- `products`: Product catalog with profitability metrics
- `order_items`: Complete sales fact table (incremental for efficiency)
- `product_performance`: Aggregated product metrics with rankings
- `sales_by_store_month`: Store performance trends

**Materialization:** Tables for query performance, Incremental for large fact table (`order_items`)

---

## 🚀 Getting Started

### Prerequisites

- **dbt Core** 1.0+ installed ([installation guide](https://docs.getdbt.com/docs/core/installation))
- **BigQuery** access with OAuth authentication
- **GCP Project** configured
- **gcloud CLI** authenticated

### Environment Setup

1. **Set environment variables:**
```bash
export DBT_PROJECT=your-gcp-project-id
export DBT_DEV_SCHEMA=your_username
```

2. **Authenticate with GCP:**
```bash
gcloud auth application-default login
```

3. **Update profiles.yml** (if needed):
The project is configured to use environment variables. Verify `profiles.yml` has the correct project reference.

### Running the Project

```bash
# Load seed data into BigQuery
dbt seed

# Run all models (staging → intermediate → marts)
dbt run

# Run tests to validate data quality
dbt test

# Full build (seeds + models + tests in dependency order)
dbt build

# Run specific layers
dbt run --select staging
dbt run --select intermediate
dbt run --select marts

# Generate and view documentation
dbt docs generate
dbt docs serve
```

### Exploring the Project

Once running, navigate to `http://localhost:8080` to explore:
- **Lineage graph**: Visual representation of model dependencies
- **Model documentation**: Purpose, columns, tests for each model
- **Column-level details**: Descriptions and data types
- **Test results**: See which quality checks are enforced

---

## ✨ What Makes This a Good Example?

### Architecture Patterns

✅ **Clean medallion architecture** → Progressive data refinement with clear separation of concerns

✅ **Strategic materialization** → Views for staging (freshness), tables for marts (performance), incremental for large facts

✅ **Domain-driven organization** → Models grouped by business domain (customers, orders, products) for easier navigation

✅ **Consistent naming conventions** → `stg_`, `int_`, no prefix for marts - self-documenting structure

### Data Quality

✅ **100+ comprehensive tests** → Confidence in data accuracy at every layer

✅ **Referential integrity** → Relationship tests ensure foreign keys are valid across all joins

✅ **Business rule validation** → Customer segments, product types validated with accepted_values tests

✅ **Primary key enforcement** → Every dimension and fact table has uniqueness and not_null tests on keys

### Performance Optimization

✅ **Incremental models** → `order_items` fact table processes only new records, not full refresh

✅ **Strategic table materialization** → Tables used where downstream queries benefit (customer aggregates, enriched orders)

✅ **Window functions** → Efficient calculations for rankings, retention, and first-order identification

✅ **Pre-aggregated metrics** → Intermediate layer aggregates prevent repeated calculations in marts

### Documentation & Maintainability

✅ **Model-level documentation** → Every model has purpose, grain, and use cases documented

✅ **Column-level descriptions** → Clear data dictionary for all business fields

✅ **Test coverage visibility** → Tests serve as documentation of data contracts

✅ **Comprehensive sources** → All raw data documented with freshness checks

---

## 🧪 Data Quality & Testing

### Testing Strategy

This project implements a layered testing approach:

**Staging Layer:**
- Uniqueness of primary keys (customer_id, order_id, sku, etc.)
- Not-null constraints on required fields
- Referential integrity between tables
- Accepted values for categorical fields (product types)

**Intermediate Layer:**
- Uniqueness preservation through joins
- Not-null tests on calculated metrics
- Business logic validation (e.g., tax calculations)

**Marts Layer:**
- Comprehensive dimension table testing
- Fact table grain validation
- Business rule enforcement (customer segments, retention rates)

### Test Results

```
✅ 109 tests passing (100% success rate)
├─ Staging: 42 tests
├─ Intermediate: 21 tests
└─ Marts: 46 tests
```

### Key Test Examples

- **Relationship tests**: Ensure every order.customer_id exists in customers
- **Accepted values**: Product types must be 'Jaffle' or 'Beverage'
- **Business rules**: Customer segments must be 'High Value', 'Medium Value', or 'Low Value'
- **Uniqueness**: Every order_id appears exactly once in orders table

---

## 🗄️ Seed Data

The project uses the **Jaffle Shop** dataset - a realistic e-commerce dataset representing a food & beverage business.

### Dataset Overview

| Seed File | Rows | Description |
|-----------|------|-------------|
| `raw_customers.csv` | 935 | Customer master data |
| `raw_orders.csv` | 61,948 | Order transactions (1 year of data) |
| `raw_items.csv` | 90,900 | Order line items |
| `raw_products.csv` | 10 | Product catalog (5 Jaffles, 5 Beverages) |
| `raw_stores.csv` | 6 | Store locations with tax rates |
| `raw_supplies.csv` | 65 | Bill of materials (supplies per product) |

**Total:** 150K+ rows across 6 files

All seeds load into the `raw_jaffle_shop` dataset in BigQuery.

---

## 📈 Project Statistics

- **18 models** (6 staging, 5 intermediate, 7 marts)
- **3 data layers** following medallion architecture
- **2 analytics domains** (customer, product/sales)
- **109 quality tests** with 100% pass rate
- **6 source tables** with 150K+ rows
- **Comprehensive documentation** on all models and columns

---

## 💡 Use Cases

This project can answer real-world analytics questions:

**Customer Questions:**
- Who are our highest-value customers? → Query `customers` with `customer_segment = 'High Value'`
- What is our month-3 retention rate for the October cohort? → Query `customer_retention_cohorts`
- What's the predicted lifetime value for customers who order frequently? → Query `customer_ltv`
- Which customers are at risk of churning? → Query `customers` where `is_churned = true`

**Product Questions:**
- Which products have the highest profit margins? → Query `products` ordered by `gross_margin`
- What's our best-selling product? → Query `product_performance` ordered by `revenue_rank`
- How much does it cost to make each product? → Query `products.total_supply_cost`

**Sales Questions:**
- How are our stores performing month-over-month? → Query `sales_by_store_month` with `mom_growth_rate`
- What's our average order value by store? → Query `sales_by_store_month.avg_order_value`
- Which products drive the most orders? → Query `product_performance.num_orders_containing_product`

---

## 🎯 Learning Paths

### For Data Community Members

**Explore the DAG:**
1. Run `dbt docs serve`
2. Click on any model in the lineage graph
3. Trace dependencies upstream and downstream
4. Understand how data flows through layers

**Read the SQL:**
1. Start with a staging model like `stg_jaffle_shop__customers.sql`
2. Follow it to an intermediate model like `int_customers__order_aggregates.sql`
3. End at a mart like `customers.sql`
4. Notice how complexity builds gradually

**Understand the Tests:**
1. Open `models/staging/jaffle_shop/_jaffle_shop__models.yml`
2. See how tests are defined on columns
3. Run `dbt test` and see results
4. Try adding your own test

**Try Modifications:**
1. Add a new customer segment (e.g., "VIP" for 200+ orders)
2. Create a new metric (e.g., average days to second purchase)
3. Build a new mart model combining customers and products

### Extension Ideas

Want to practice? Try adding:
- **New marts**: Marketing attribution, financial reporting
- **Snapshots**: Track product price changes over time with SCD Type 2
- **Exposures**: Document how these models feed into BI dashboards
- **Custom tests**: Validate business rules specific to your use case
- **Macros**: Create reusable SQL functions for common patterns

---

## 🔧 Configuration

### Key Config Files

**`dbt_project.yml`**
- Defines materializations by layer (views → tables → incremental)
- Sets schema names for each layer
- Configures tags for selective runs

**`profiles.yml`**
- BigQuery connection parameters
- Development and production targets
- OAuth authentication method

**`macros/generate_schema_name.sql`**
- Custom schema naming logic
- Allows clean schema separation without prefixes

---

## 🚀 CI/CD & Automation

This project includes automated workflows for continuous integration and deployment.

### GitHub Actions Workflows

**CI Workflow (Pull Requests)**
- Triggers on pull requests to `main` branch
- Uses **Slim CI** - only builds modified models and their downstream dependencies
- Runs against `dev` target (dev_analytics dataset)
- Validates changes before merge
- Execution time: ~1-2 minutes for small changes

**CD Workflow (Production Deployment)**
- Triggers on merge to `main` branch
- Runs full production build against `prod` target (analytics dataset)
- Generates documentation
- Uploads production manifest for future CI runs
- Execution time: ~7-10 minutes

### Pre-commit Hooks

Pre-commit hooks run automatically before each commit to catch issues early:

**Enabled Hooks:**
- Security: Private key detection
- File quality: Trailing whitespace, end-of-file fixes
- YAML validation: Validates dbt YAML files
- SQL linting: SQLFluff with BigQuery dialect
- dbt best practices: No semicolons, enforce ref()/source()

**Setup:**
```bash
# Install pre-commit
pip install pre-commit sqlfluff sqlfluff-templater-dbt

# Install hooks
pre-commit install

# Test on all files
pre-commit run --all-files
```

---

## 📚 Resources

### Learn More About dbt

- [dbt Documentation](https://docs.getdbt.com/)
- [dbt Best Practices](https://docs.getdbt.com/guides/best-practices)
- [dbt Discourse Community](https://discourse.getdbt.com/)

### Medallion Architecture

- [Medallion Architecture Explained](https://www.databricks.com/glossary/medallion-architecture)
- [Data Modeling Best Practices](https://www.getdbt.com/analytics-engineering/modular-data-modeling-technique/)

### BigQuery

- [BigQuery Documentation](https://cloud.google.com/bigquery/docs)
- [BigQuery SQL Reference](https://cloud.google.com/bigquery/docs/reference/standard-sql/query-syntax)

---

## 🤝 Contributing & Feedback

This project is created as a **learning resource for the data community**. Feedback, questions, and suggestions are welcome!

**Ways to engage:**
- Open an issue with questions or suggestions
- Share how you've adapted this pattern for your use case
- Suggest additional analytics use cases to showcase
- Contribute improvements to documentation or code

**Learning together** is what makes the data community strong. This project is part of that journey.

---

## 📝 License

This project is open source and available for educational purposes.

---

**Built with ❤️ for the data community | Powered by dbt Core + BigQuery**
