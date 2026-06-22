# SQL Data Warehouse (CRM + ERP)

A small SQL Server data warehouse built with the **medallion architecture** (Bronze → Silver → Gold). It ingests raw CRM and ERP CSV extracts, cleans/standardizes them, and exposes an analytics-ready star schema for sales reporting.

## Architecture

```mermaid
flowchart LR
    subgraph Sources
        CRM[("CRM")]
        ERP[("ERP")]
    end

    subgraph Bronze["Bronze Layer"]
        b1[crm_sales_details]
        b2[crm_cust_info]
        b3[crm_prd_info]
        b4[erp_cust_az12]
        b5[erp_loc_a101]
        b6[erp_px_cat_g1v2]
    end

    subgraph Silver["Silver Layer"]
        s1[crm_sales_details]
        s2[crm_cust_info]
        s3[crm_prd_info]
        s4[erp_cust_az12]
        s5[erp_loc_a101]
        s6[erp_px_cat_g1v2]
    end

    subgraph Gold["Gold Layer"]
        g1[fact_sales]
        g2[dim_customers]
        g3[dim_products]
    end

    CRM --> b1 & b2 & b3
    ERP --> b4 & b5 & b6

    b1 --> s1
    b2 --> s2
    b3 --> s3
    b4 --> s4
    b5 --> s5
    b6 --> s6

    s1 --> g1
    s2 --> g2
    s4 --> g2
    s5 --> g2
    s3 --> g3
    s6 --> g3
    g2 --> g1
    g3 --> g1
```

- **Bronze** — raw load of CRM (`cust_info`, `prd_info`, `sales_details`) and ERP (`CUST_AZ12`, `LOC_A101`, `PX_CAT_G1V2`) CSVs, no transformations.
- **Silver** — deduplicated, type-corrected, and standardized data (e.g. normalized gender/marital status codes, valid date ranges), with a `dwh_create_date` audit column.
- **Gold** — business-facing views joining Silver tables into a star schema for BI/reporting.

## Gold Layer Schema

```
        gold.dim_customers
               │
               ▼
gold.dim_products ──► gold.fact_sales ◄── gold.dim_customers
```

| View | Type | Key Columns |
|---|---|---|
| `gold.dim_customers` | Dimension | `customer_key` (PK), `customer_id`, `customer_number`, `first_name`, `last_name`, `country`, `gender`, `birthdate` |
| `gold.dim_products` | Dimension | `product_key` (PK), `product_id`, `product_number`, `product_name`, `category`, `subcategory`, `cost` |
| `gold.fact_sales` | Fact | `order_number`, `product_key` (FK), `customer_key` (FK), `order_date`, `sales_amount`, `quantity`, `price` |

## Project Structure

```
scripts/
├── init_database.sql           # creates DataWarehouse db + bronze/silver/gold schemas
├── bronze/
│   ├── ddl_bronze.sql           # raw table definitions
│   └── proc_load_bronze.sql     # bulk-loads CSVs into bronze
├── silver/
│   ├── ddl_silver.sql           # cleaned table definitions
│   ├── proc_load_silver.sql     # transform + load bronze → silver
│   └── silver_testing.sql       # data quality checks
├── gold/
│   └── ddl_gold.sql             # star schema views (dims + fact)
└── execute.sql                  # run the full pipeline
source_crm/                      # raw CRM CSV extracts
source_erp/                      # raw ERP CSV extracts
```

## How to Run

1. Run `scripts/init_database.sql` to create the `DataWarehouse` database and schemas.
2. Run `scripts/bronze/ddl_bronze.sql` then `scripts/bronze/proc_load_bronze.sql`, and execute `EXEC bronze.load_bronze;`.
3. Run `scripts/silver/ddl_silver.sql` then `scripts/silver/proc_load_silver.sql`, and execute `EXEC silver.load_silver;`.
4. Run `scripts/gold/ddl_gold.sql` to create the reporting views.

## Tech Stack

SQL Server (T-SQL), CSV file ingestion (`BULK INSERT`).
