/*
===============================================================================
Quality Checks: Gold Layer
===============================================================================
Purpose:
    Confirm gold views joined dimensions onto the fact table correctly --
    no exploded row counts from bad join keys and no dropped/orphaned rows.
    All checks below should return 0 rows unless noted otherwise.
===============================================================================
*/
USE DataWarehouse;
GO

-- No orphaned keys in the fact table (a NULL means the dimension join missed)
SELECT *
FROM gold.fact_sales
WHERE product_key IS NULL OR customer_key IS NULL;

-- Surrogate keys are unique per dimension
SELECT customer_key, COUNT(*) AS cnt
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;

SELECT product_key, COUNT(*) AS cnt
FROM gold.dim_products
GROUP BY product_key
HAVING COUNT(*) > 1;

-- Row count sanity: the fact view should not exceed silver sales rows
-- (a one-to-many join key would silently inflate this)
SELECT
    (SELECT COUNT(*) FROM silver.crm_sales_details) AS silver_count,
    (SELECT COUNT(*) FROM gold.fact_sales)           AS gold_count;
