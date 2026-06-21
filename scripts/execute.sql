USE DataWarehouse;
EXEC bronze.load_bronze;

EXEC silver.load_silver;

SELECT * FROM 
silver.crm_cust_info;
