USE DataWareHouse;


SELECT * 
FROM silver.crm_cust_info


SELECT * 
FROM silver.crm_prd_info

SELECT * 
FROM bronze.crm_sales_details


SELECT *
from bronze.crm_sales_details 
WHERE sls_cust_id NOT IN (SELECT cst_id FROM silver.crm_cust_info)


SELECT * 
FROm silver.crm_sales_details
WHERE sls_sales IS NULL OR sls_sales != sls_quantity * sls_price 

SELECT DISTINCT(cntry)
FROM silver.erp_loc_a101
