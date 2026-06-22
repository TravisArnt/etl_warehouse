/*
===============================================================================
Quality Checks: Silver Layer
===============================================================================
Purpose:
    Confirm bronze -> silver transformations worked as intended: dedup,
    standardized codes, and no invalid values. Run after EXEC silver.load_silver.
    All checks below should return 0 rows unless noted otherwise.
===============================================================================
*/
USE DataWarehouse;
GO

-- No duplicate customer IDs after dedup (kept most recent record per cst_id)
SELECT cst_id, COUNT(*) AS cnt
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1;

-- No NULLs in critical customer fields
SELECT *
FROM silver.crm_cust_info
WHERE cst_id IS NULL OR cst_key IS NULL;

-- Gender is standardized to 'Male', 'Female', or 'n/a'
SELECT DISTINCT cst_gndr
FROM silver.crm_cust_info
WHERE cst_gndr NOT IN ('Male', 'Female', 'n/a');

-- Marital status is standardized to 'Married', 'Single', or 'n/a'
SELECT DISTINCT cst_marital_status
FROM silver.crm_cust_info
WHERE cst_marital_status NOT IN ('Married', 'Single', 'n/a');

-- No negative product costs
SELECT *
FROM silver.crm_prd_info
WHERE prd_cost < 0;

-- Product start date never after end date
SELECT *
FROM silver.crm_prd_info
WHERE prd_end_dt IS NOT NULL AND prd_start_dt > prd_end_dt;

-- Sales = quantity * price for every row (rule enforced during load)
SELECT *
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price;

-- No negative or zero quantity/price/sales
SELECT *
FROM silver.crm_sales_details
WHERE sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0;

-- ERP birthdates are not in the future
SELECT *
FROM silver.erp_cust_az12
WHERE bdate > GETDATE();
