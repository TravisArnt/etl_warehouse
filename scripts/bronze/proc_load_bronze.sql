CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME
    BEGIN TRY
        PRINT('====================================');
        PRINT('Executing the Bronze Procedure');
        PRINT('====================================');

        PRINT('-------------------------------------');
        PRINT('Loading CRM data');
        PRINT('-------------------------------------');

        SET @start_time = GETDATE()
        PRINT('>> Truncating crm_cust_info table');
        TRUNCATE TABLE bronze.crm_cust_info;
        PRINT('>> Inserting data into crm_cust_info table');
        BULK INSERT bronze.crm_cust_info
        FROM '/var/opt/mssql/source_crm/cust_info.csv'
        WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', TABLOCK);
        

        PRINT('>> Truncating crm_prd_info table');
        TRUNCATE TABLE bronze.crm_prd_info;
        PRINT('>> Inserting data into crm_prd_info table');
        BULK INSERT bronze.crm_prd_info
        FROM '/var/opt/mssql/source_crm/prd_info.csv'
        WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', TABLOCK);

        PRINT('>> Truncating crm_sales_details table');
        TRUNCATE TABLE bronze.crm_sales_details;
        PRINT('>> Inserting data into crm_sales_details table');
        BULK INSERT bronze.crm_sales_details
        FROM '/var/opt/mssql/source_crm/sales_details.csv'
        WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', TABLOCK);
        
        PRINT('-------------------------------------');
        PRINT('Loading ERP data');
        PRINT('-------------------------------------');

        PRINT('>> Truncating erp_loc_a101 table');
        TRUNCATE TABLE bronze.erp_loc_a101;
        PRINT('>> Inserting data into erp_loc_a101 table');
        BULK INSERT bronze.erp_loc_a101
        FROM '/var/opt/mssql/source_erp/LOC_A101.csv'
        WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', TABLOCK);

        PRINT('>> Truncating erp_cust_az12 table');
        TRUNCATE TABLE bronze.erp_cust_az12;
        PRINT('>> Inserting data into erp_cust_az12 table');
        BULK INSERT bronze.erp_cust_az12
        FROM '/var/opt/mssql/source_erp/CUST_AZ12.csv'
        WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', TABLOCK);

        PRINT('>> Truncating erp_px_cat_g1v2 table');
        TRUNCATE TABLE bronze.erp_px_cat_g1v2;
        PRINT('>> Inserting data into erp_px_cat_g1v2 table');
        BULK INSERT bronze.erp_px_cat_g1v2
        FROM '/var/opt/mssql/source_erp/PX_CAT_G1V2.csv'
        WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', TABLOCK);
        SET @end_time = GETDATE()
        PRINT('---------------------------')
        PRINT'>> Load Duration:' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds';
        PRINT('---------------------------')

    END TRY
    BEGIN CATCH
    PRINT('------------------------------');
    PRINT('Error Occured')
    END CATCH
END