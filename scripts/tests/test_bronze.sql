/*
===============================================================================
Quality Checks: Bronze Layer
===============================================================================
Purpose:
    Confirm raw CSV loads landed intact in bronze — no silent load failures
    or fully-empty rows. Run after EXEC bronze.load_bronze.
    All checks below should return 0 rows / non-zero counts.
===============================================================================
*/
USE DataWarehouse;
GO

-- Row counts are non-zero
SELECT 'bronze.crm_cust_info'     AS table_name, COUNT(*) AS row_count FROM bronze.crm_cust_info
UNION ALL
SELECT 'bronze.crm_prd_info',      COUNT(*) FROM bronze.crm_prd_info
UNION ALL
SELECT 'bronze.crm_sales_details', COUNT(*) FROM bronze.crm_sales_details
UNION ALL
SELECT 'bronze.erp_cust_az12',     COUNT(*) FROM bronze.erp_cust_az12
UNION ALL
SELECT 'bronze.erp_loc_a101',      COUNT(*) FROM bronze.erp_loc_a101
UNION ALL
SELECT 'bronze.erp_px_cat_g1v2',   COUNT(*) FROM bronze.erp_px_cat_g1v2;

-- No fully empty sales rows (both order number and customer id missing)
SELECT COUNT(*) AS empty_sales_rows
FROM bronze.crm_sales_details
WHERE sls_ord_num IS NULL AND sls_cust_id IS NULL; -- expect 0
