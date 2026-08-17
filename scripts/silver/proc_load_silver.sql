/*
==========================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
==========================================================================

Script Purpose:
This stored procedure performs the ETL (Extract, Transform, Load) process to populate the
'silver' schema tables from the 'bronze' schema.

Actions Performed:
  - Truncates Silver tables.
  - Inserts transformed and cleansed data from Bronze into Silver tables.

Parameters:
  None.
  This stored procedure does not accept any parameters or return any values.

Usage Example:
  EXEC Silver.load_silver;
==========================================================================
*/


CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN

    DECLARE @end_time DATETIME, @start_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
    BEGIN TRY

    PRINT '================================================================';
    PRINT 'Loading the Silver Layer'
    PRINT '================================================================';

    PRINT '----------------------------------------------------------------';
    PRINT 'Loading the CRM Tables'
    PRINT '----------------------------------------------------------------';

    SET @batch_start_time = GETDATE();
    SET @start_time = GETDATE();

    PRINT '----------------------------------------------------------------------------------------------------------------------------------------'
    PRINT 'TRUNCATING TABLE : Silver.crm_cust_info'
    TRUNCATE TABLE Silver.crm_cust_info
    PRINT 'INSERTING TABLE : Silver.crm_cust_info'
    INSERT INTO Silver.crm_cust_info (
        cst_id,
        cst_key,
        cst_firstname,
        cst_lastname,
        cst_marital_status,
        cst_gndr,
        cst_create_date
    )
    select 
        cst_id,
        cst_key,
        TRIM(cst_firstname) as cst_firstname,
        TRIM(cst_lastname) as cst_lastname,

        CASE 
            WHEN UPPER(TRIM(cst_marital_status)) = 'S' then 'Single'
            WHEN UPPER(TRIM(cst_marital_status)) = 'M' then 'Married'
            else 'N/A'
        END as cst_marital_status,

        CASE 
            WHEN UPPER(TRIM(cst_gndr)) = 'M' then 'Male'
            WHEN UPPER(TRIM(cst_gndr)) = 'F' then ' Female'
            ELSE 'N/A'
        END as cst_gender,
        cst_create_date

    from (
    select *,
    ROW_NUMBER() over(partition by cst_id order by cst_create_date desc) as flag_last 
    from bronze.crm_cust_info
    where cst_id is not null
    )t
    where flag_last = 1
    SET @end_time = GETDATE();

    PRINT '>> Load Duration :' + CAST(DATEDIFF(SECOND, @start_time, @end_time) as NVARCHAR) + 'seconds'
    PRINT '----------------------------------------------'

    SET @start_time = GETDATE();
    PRINT '----------------------------------------------------------------------------------------------------------------------------------------'
    PRINT 'TRUNCATING TABLE : Silver.crm_prd_info'

    TRUNCATE TABLE Silver.crm_prd_info;
    PRINT 'INSERTING TABLE : Silver.crm_prd_info'
    INSERT INTO Silver.crm_prd_info(
            prd_id,
            cat_id,
            prd_key,
            prd_nm, 
            prd_cost,
            prd_line,
            prd_start_dt, 
            prd_end_dt
            )
    select  
        prd_id,
        REPLACE(SUBSTRING(prd_key, 1, 5),'-', '_') as cat_id, -- extract cat id
        SUBSTRING(prd_key,7, LEN(prd_key)) as prod_key, -- extract prd id
        prd_nm, 
        ISNULL(prd_cost, 0) as prod_cost,
        CASE UPPER(TRIM(prd_line))
            WHEN 'M' then 'Mountain'
            WHEN 'R' then 'Road'
            WHEN 'S' then 'Other Sales'
            WHEN 'T' then 'Touring'
            else 'N/A'
        END as 
        prd_line,
        CAST(prd_start_dt AS DATE) as prod_start_dt,
        CAST(LEAD(prd_start_dt) OVER(partition by prd_key order by prd_start_dt) - 1 AS DATE) as prod_end_date

    from bronze.crm_prd_info
    SET @end_time = GETDATE();
    PRINT '>> Load Duration :' + CAST(DATEDIFF(SECOND, @start_time, @end_time) as NVARCHAR) + 'seconds'

    SET @start_time = GETDATE();
    PRINT '----------------------------------------------------------------------------------------------------------------------------------------'
    PRINT 'TRUNCATING TABLE : Silver.crm_sales_details'

    TRUNCATE TABLE Silver.crm_sales_details
    PRINT 'INSERTING TABLE : Silver.crm_sales_details'

    INSERT INTO Silver.crm_sales_details(
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

    select 
        sls_ord_num,
        sls_prd_key,
        sls_cust_id,
        CASE
            WHEN sls_order_dt <= 0 OR LEN(sls_order_dt) != 8 THEN NULL
            ELSE CAST(CAST(sls_order_dt as VARCHAR) as DATE)
        END as sls_order_dt,       -- you cant type cast directly from int to date u have to convrt into varchar

        CASE
            WHEN sls_ship_dt <= 0 OR LEN(sls_ship_dt) != 8 THEN NULL
            ELSE CAST(CAST(sls_ship_dt as VARCHAR) as DATE)
        END as sls_ship_dt,

        CASE
            WHEN sls_due_dt <= 0 OR LEN(sls_due_dt) != 8 THEN NULL
            ELSE CAST(CAST(sls_due_dt as VARCHAR) as DATE)
        END as sls_due_dt,

        CASE 
            WHEN sls_sales is NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
            THEN sls_quantity * ABS(sls_price)
            ELSE sls_sales
        END AS sls_sales,

            sls_quantity,

        CASE
            WHEN sls_price <= 0 OR sls_price is NULL THEN sls_sales/NULLIF(sls_quantity,0)
            ELSE sls_price
        END AS sls_price 
        
    from [bronze].[crm_sales_details]
    SET @end_time = GETDATE();
    PRINT '>> Load Duration :' + CAST(DATEDIFF(SECOND, @start_time, @end_time) as NVARCHAR) + 'seconds'



    PRINT '----------------------------------------------------------------';
    PRINT 'Loading the ERP Tables'
    PRINT '----------------------------------------------------------------';

    SET @start_time = GETDATE();
    PRINT '----------------------------------------------------------------------------------------------------------------------------------------'
    PRINT 'TRUNCATING TABLE : silver.erp_cust_az12'

    TRUNCATE TABLE silver.erp_cust_az12
    PRINT 'INSERTING TABLE : silver.erp_cust_az12'

    INSERT INTO silver.erp_cust_az12 (cid,bdate,gen )

    SELECT 
    CASE 
        WHEN cid like 'NAS%' then SUBSTRING(cid, 4, LEn(cid))
        ELSE cid
    END as cid,

    CASE 
        WHEN bdate < '1924-01-01' OR bdate > GETDATE() THEN NULL
        ELSE bdate
    end as bdate,

    CASE
        WHEN UPPER(TRIM(REPLACE(REPLACE(gen, CHAR(13), ''),CHAR(10), ''))) IN ('F', 'FEMALE') THEN 'Female'
        WHEN UPPER(TRIM(REPLACE(REPLACE(gen, CHAR(13), ''),CHAR(10), ''))) IN ('M', 'MALE') THEN 'Male'
        ELSE 'N/A'
        END AS gen 
    from bronze.erp_cust_az12;
    SET @end_time = GETDATE();
    PRINT '>> Load Duration :' + CAST(DATEDIFF(SECOND, @start_time, @end_time) as NVARCHAR) + 'seconds'



    SET @start_time = GETDATE();
    PRINT '----------------------------------------------------------------------------------------------------------------------------------------'
    PRINT 'TRUNCATING TABLE : Silver.erp_loc_a101'

    TRUNCATE TABLE Silver.erp_loc_a101
    PRINT 'INSERTING TABLE : Silver.erp_loc_a101'

    Insert INTO Silver.erp_loc_a101 (cid,cntry)

    select REPLACE(cid,'-','') as cid,
    CASE
            WHEN UPPER(TRIM(REPLACE(REPLACE(cntry, CHAR(13), ''),CHAR(10), ''))) IN ('France') THEN 'France'
            WHEN UPPER(TRIM(REPLACE(REPLACE(cntry, CHAR(13), ''),CHAR(10), ''))) IN ('US','USA','United States') THEN 'United States'
            WHEN UPPER(TRIM(REPLACE(REPLACE(cntry, CHAR(13), ''),CHAR(10), ''))) IN ('Germany','DE') THEN 'Germany'
            WHEN UPPER(TRIM(REPLACE(REPLACE(cntry, CHAR(13), ''),CHAR(10), ''))) IN ('Australia') THEN 'Australia'
            WHEN UPPER(TRIM(REPLACE(REPLACE(cntry, CHAR(13), ''),CHAR(10), ''))) IN ('United Kingdom') THEN 'United Kingdom'
            WHEN UPPER(TRIM(REPLACE(REPLACE(cntry, CHAR(13), ''),CHAR(10), ''))) IN ('Canada') THEN 'Canada'
            ELSE 'N/A'
        END AS cntry
    from bronze.erp_loc_a101
    SET @end_time = GETDATE();
    PRINT '>> Load Duration :' + CAST(DATEDIFF(SECOND, @start_time, @end_time) as NVARCHAR) + 'seconds'


    SET @start_time = GETDATE();
    PRINT '----------------------------------------------------------------------------------------------------------------------------------------'
    PRINT 'TRUNCATING TABLE : silver.erp_px_cat_g1v2'

    TRUNCATE TABLE silver.erp_px_cat_g1v2
    PRINT 'INSERTING TABLE : silver.erp_px_cat_g1v2'

    INSERT Into silver.erp_px_cat_g1v2(id, cat, subcat, maintenance)
    select 
        id,
        cat,
        subcat,
        CASE
            WHEN UPPER(TRIM(REPLACE(REPLACE(maintenance, CHAR(13), ''),CHAR(10), ''))) IN ('No') THEN 'No'
            WHEN UPPER(TRIM(REPLACE(REPLACE(maintenance, CHAR(13), ''),CHAR(10), ''))) IN ('Yes', 'MALE') THEN 'Yes'
            ELSE maintenance
        END AS maintenance
        from bronze.erp_px_cat_g1v2
        SET @end_time = GETDATE();
        PRINT '>> Load Duration :' + CAST(DATEDIFF(SECOND, @start_time, @end_time) as NVARCHAR) + 'seconds'
    SET @batch_end_time = GETDATE();

    PRINT '>>Total Load Duration :' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) as NVARCHAR) + 'seconds'
    PRINT '----------------------------------------------'

    END TRY
    BEGIN CATCH
    PRINT '================================================================';
    PRINT 'ERROR OCCURED DURING LOADING THE BRONZE LAYER'    
    PRINT 'ERROR MESSAGE' + ERROR_MESSAGE();
    PRINT 'ERROR NUMBER ' + CAST(ERROR_NUMBER() AS NVARCHAR);
    PRINT 'ERROR STATE ' + CAST(ERROR_STATE() AS NVARCHAR);
    PRINT '================================================================';

    END CATCH

END 

EXEC Silver.load_silver
