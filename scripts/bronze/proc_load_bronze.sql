USE DataWarehouse;
GO

TRUNCATE TABLE bronze.crm_cust_info;

BULK INSERT bronze.crm_cust_info
FROM '/var/opt/mssql/source_crm/cust_info.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR =',',
    TABLOCK
);

TRUNCATE TABLE bronze.crm_prd_info

BULK INSERT bronze.crm_prd_info 
FROM '/var/opt/mssql/source_crm/prd_info.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR =',',
    TABLOCK
);

TRUNCATE TABLE bronze.crm_sales_details

BULK INSERT bronze.crm_sales_details 
FROM '/var/opt/mssql/source_crm/sales_details.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR =',',
    TABLOCK
);


