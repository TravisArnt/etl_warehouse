CREATE OR ALTER PROCEDURE silver.load_silver AS 
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME
    BEGIN TRY
    PRINT('====================================');
    PRINT('Executing the Silver Procedure');
    PRINT('====================================');


    PRINT('>>Truncating crm_prd_info table')
    TRUNCATE TABLE silver.crm_prd_info
    PRINT('>>Inserting data into crm_prd_info table')

    INSERT INTO silver.crm_prd_info(
        prd_id,
        cat_id,
        prd_key,
        prd_nm,
        prd_cost,
        prd_line,
        prd_start_dt,
        prd_end_dt
    )
    SELECT 
        prd_id,
        SUBSTRING(prd_key,1,5) AS cat_id,
        SUBSTRING(prd_key,7,LEN(prd_key)) AS prod_key,
        prd_nm,
        ISNULL(prd_cost,0) AS prd_cost,
        CASE UPPER(TRIM(prd_line))
        WHEN 'R' THEN 'Road'
        WHEN 'M' THEN 'Mountain'
        WHEN 'S' THEN 'Other Sales'
        WHEN 'T' THEN 'Touring'
        ELSE 'n/a' 
        END AS prd_line,
        CAST(prd_start_dt AS DATE) AS prd_start_dt,
        CAST(LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt)-1 AS DATE) AS prd_end_dt
    FROM bronze.crm_prd_info


    PRINT('>>Truncating crm_cust_info table')
    TRUNCATE TABLE silver.crm_cust_info
    PRINT('>>Inserting data into crm_cust_info table')
    INSERT INTO silver.crm_cust_info (
        cst_id,
        cst_key,
        cst_firstname,
        cst_lastname,
        cst_marital_status,
        cst_gndr,
        cst_create_date
    )

    SELECT 
        cst_id, 
        cst_key,
        TRIM(cst_firstname) AS cst_firstname,
        TRIM(cst_lastname) AS cst_lastname,
        CASE 
            WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
            WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
            ELSE 'n/a'
        END AS cst_marital_status,
        CASE 
            WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
            WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
            ELSE 'n/a'
        END AS cst_gndr,
        cst_create_date
    FROM (
    SELECT *, ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) AS 'flag_last'
    FROM bronze.crm_cust_info
    ) t
    WHERE flag_last = 1 AND cst_id IS NOT NULL



    PRINT('>>Truncating crm_sales_details table')
    TRUNCATE TABLE silver.crm_cust_info
    PRINT('>>Inserting data into crm_sales_details table')
    INSERT INTO silver.crm_sales_details(
        sls_ord_num,
        sls_prd_key,
        sls_cust_id,
        sls_order_dt,
        sls_ship_dt,
        sls_due_dt,
        sls_sales,
        sls_quantity,
        sls_price
    )

    SELECT 
        sls_ord_num,
        sls_prd_key,
        sls_cust_id,
        CASE WHEN sls_order_dt = 0 OR sls_order_dt IS NULL OR LEN(sls_order_dt) != 8 THEN NULL ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE) END AS sls_order_dt,
        CASE WHEN sls_ship_dt = 0 OR sls_ship_dt IS NULL OR LEN(sls_ship_dt) != 8 THEN NULL ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE) END AS sls_ship_dt,
        CASE WHEN sls_due_dt = 0 OR sls_due_dt IS NULL OR LEN(sls_due_dt) != 8 THEN NULL ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE) END AS sls_due_dt,
        CASE WHEN sls_sales IS NULL OR sls_sales < 0 OR sls_sales != sls_quantity * ABS(sls_price) THEN sls_quantity * ABS(sls_price) ELSE sls_sales END AS sls_sales,
        sls_quantity,
        CASE WHEN sls_price IS NULL OR sls_price < 0 THEN ABS(sls_sales / NULLIF(sls_quantity,0)) ELSE ABS(sls_price) END AS sls_price
    FROM bronze.crm_sales_details



    PRINT('>>Truncating erp_cust_az12 table')
    TRUNCATE TABLE silver.erp_cust_az12
    PRINT('>>Inserting data into erp_cust_az12 table')
    INSERT INTO silver.erp_cust_az12(
        cid,
        bdate,
        gen
    )
    SELECT 
        CASE WHEN TRIM(cid) LIKE 'NAS%' THEN SUBSTRING(cid,4,LEN(cid)) ELSE TRIM(cid) END AS cid,
        CASE WHEN bdate > GETDATE() THEN NULL ELSE bdate END AS bdate,
        CASE WHEN UPPER(TRIM(REPLACE(REPLACE(gen, CHAR(13), ''), CHAR(10), ''))) IN ('M', 'MALE') THEN 'Male' 
            WHEN UPPER(TRIM(REPLACE(REPLACE(gen, CHAR(13), ''), CHAR(10), ''))) IN ('F', 'FEMALE') THEN 'Female' 
            ELSE 'n/a' 
            END AS gen
    FROM bronze.erp_cust_az12


    PRINT('>>Truncating erp_px_cat_g1v2 table')
    TRUNCATE TABLE silver.erp_px_cat_g1v2
    PRINT('>>Inserting data into erp_px_cat_g1v2 table')
    INSERT INTO silver.erp_px_cat_g1v2(
        id,
        cat,
        subcat,
        maintenance
    )
    SELECT 
        Id,
        cat,
        subcat,
        maintenance
    FROM bronze.erp_px_cat_g1v2


    PRINT('>>Truncating erp_loc_a101 table')
    TRUNCATE TABLE silver.erp_loc_a101
    PRINT('>>Inserting data into erp_loc_a101 table')
    INSERT INTO silver.erp_loc_a101 (
        cid,
        cntry
    )
    SELECT 
    REPLACE(cid,'-','') AS cid,
    CASE 
            WHEN TRIM(REPLACE(REPLACE(cntry, CHAR(13), ''), CHAR(10), '')) IN ('US','USA') THEN 'United States'
            WHEN TRIM(REPLACE(REPLACE(cntry, CHAR(13), ''), CHAR(10), '')) = 'DE' THEN 'Germany'
            WHEN TRIM(REPLACE(REPLACE(cntry, CHAR(13), ''), CHAR(10), '')) = '' OR cntry IS NULL THEN 'n/a'
            ELSE TRIM(REPLACE(REPLACE(cntry, CHAR(13), ''), CHAR(10), ''))
        END AS cntry
    FROM bronze.erp_loc_a101 
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

