/*
===================================
DDL Script: Create Bronze Tables
===================================
Script Purpose:
This script creates tables in the 'bronze' schema, dropping existing tables if they already exist.
Run this script to re-define the DDL structure of 'bronze' Tables
================================================================================================================
*/

IF OBJECT_ID ('bronze.crm_cust_info', 'U') IS NOT NULL
        DROP TABLE bronze.crm_cust_info;
    CREATE TABLE bronze.crm_cust_info(
        cst_id INT,
        cst_key	NVARCHAR(50),
        cst_firstname NVARCHAR(50),
        cst_lastname NVARCHAR(50),
        cst_marital_status	NVARCHAR(50),
        cst_gndr NVARCHAR(50),
        cst_create_date DATE
    );


    IF OBJECT_ID ('bronze.crm_prd_info', 'U') IS NOT NULL
        DROP TABLE bronze.crm_prd_info;
    CREATE TABLE bronze.crm_prd_info (
        prd_id INT,
        prd_key NVARCHAR (50),
        prd_nm NVARCHAR (50) ,
        prd_cost INT,
        prd_line NVARCHAR (50),
        prd_start_dt DATETIME, 
        prd_end_dt DATETIME
    );


    IF OBJECT_ID ('bronze.crm_sales_details', 'U') IS NOT NULL
        DROP TABLE bronze.crm_sales_details;
    CREATE TABLE bronze.crm_sales_details ( 
        sls_ord_num NVARCHAR (50) ,
        sls_prd_key NVARCHAR (50),
        sls_cust_id INT,
        sls_order_dt INT,
        sls_ship_dt INT,
        sls_due_dt INT,
        sls_sales INT,
        sls_quantity INT,
        sls_price INT
    ) ;


    IF OBJECT_ID ('bronze.erp_loc_a101', 'U') IS NOT NULL
        DROP TABLE bronze.erp_loc_a101;
    CREATE TABLE bronze.erp_loc_a101 (
        cid NVARCHAR (50),
        cntry NVARCHAR (50)
    );

    IF OBJECT_ID ('bronze.erp_cust_az12', 'U') IS NOT NULL
        DROP TABLE bronze.erp_cust_az12;
    CREATE TABLE bronze.erp_cust_az12 (
        cid NVARCHAR (50),
        bdate DATE,
        gen NVARCHAR(50)
    );


    IF OBJECT_ID ('bronze.erp_px_cat_g1v2', 'U') IS NOT NULL
        DROP TABLE bronze.erp_px_cat_g1v2;
    CREATE TABLE bronze.erp_px_cat_g1v2 (
        id NVARCHAR (50),
        cat NVARCHAR (50),
        subcat NVARCHAR (50),
        maintenance NVARCHAR(50) 
    );

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
    DECLARE @end_time DATETIME, @start_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
    BEGIN TRY

    PRINT '================================================================';
    PRINT 'Loading the Bronze Layer'
    PRINT '================================================================';

    PRINT '----------------------------------------------------------------';
    PRINT 'Loading the CRM Tables'
    PRINT '----------------------------------------------------------------';

    SET @batch_start_time = GETDATE();
    SET @start_time = GETDATE();

    PRINT '>> Truncating Table: bronze.crm_cust_info'
    TRUNCATE TABLE bronze.crm_cust_info;
    PRINT '>> Inserting Data Into: bronze.crm_cust_info'
    BULK INSERT bronze.crm_cust_info
    FROM '/var/opt/mssql/datasets/source_crm/cust_info.csv'
    WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ','
    );
    SET @end_time = GETDATE();

    PRINT '>> Load Duration :' + CAST(DATEDIFF(SECOND, @start_time, @end_time) as NVARCHAR) + 'seconds'
    PRINT '----------------------------------------------'


    SET @start_time = GETDATE();
    PRINT '>> Truncating Table: bronze.crm_prd_info'
    TRUNCATE TABLE bronze.crm_prd_info;
    PRINT '>> Inserting Data Into: bronze.crm_prd_info'
    BULK INSERT bronze.crm_prd_info
    FROM '/var/opt/mssql/datasets/source_crm/prd_info.csv'
    WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ','
    );
    SET @end_time = GETDATE();

    PRINT '>> Load Duration :' + CAST(DATEDIFF(SECOND, @start_time, @end_time) as NVARCHAR) + 'seconds'
    PRINT '----------------------------------------------'

    SET @start_time = GETDATE();
    PRINT '>> Truncating Table: bronze.crm_sales_details'
    TRUNCATE TABLE bronze.crm_sales_details;
    PRINT '>> Inserting Data Into: bronze.crm_sales_details'
    BULK INSERT bronze.crm_sales_details
    FROM '/var/opt/mssql/datasets/source_crm/sales_details.csv'
    WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ','
    );
    SET @end_time = GETDATE();

    PRINT '>> Load Duration :' + CAST(DATEDIFF(SECOND, @start_time, @end_time) as NVARCHAR) + 'seconds'
    PRINT '----------------------------------------------'


    PRINT '----------------------------------------------------------------';
    PRINT 'Loading the ERP Tables'
    PRINT '----------------------------------------------------------------';

    SET @start_time = GETDATE();
    PRINT '>> Truncating Table: bronze.erp_cust_az12'
    TRUNCATE TABLE bronze.erp_cust_az12;
    PRINT '>> Inserting Data Into: bronze.erp_cust_az12'
    BULK INSERT bronze.erp_cust_az12
    FROM '/var/opt/mssql/datasets/source_erp/cust_az12.csv'
    WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ','
    );
    SET @end_time = GETDATE();

    PRINT '>> Load Duration :' + CAST(DATEDIFF(SECOND, @start_time, @end_time) as NVARCHAR) + 'seconds'
    PRINT '----------------------------------------------'

    SET @start_time = GETDATE();
    PRINT '>> Truncating Table: bronze.erp_loc_a101'
    TRUNCATE TABLE bronze.erp_loc_a101;
    PRINT '>> Inserting Data Into: bronze.erp_loc_a101'
    BULK INSERT bronze.erp_loc_a101
    FROM '/var/opt/mssql/datasets/source_erp/loc_a101.csv'
    WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ','
    );
    SET @end_time = GETDATE();

    PRINT '>> Load Duration :' + CAST(DATEDIFF(SECOND, @start_time, @end_time) as NVARCHAR) + 'seconds'
    PRINT '----------------------------------------------'

    SET @start_time = GETDATE();
    PRINT '>> Truncating Table: bronze.erp_px_cat_g1v2'
    TRUNCATE TABLE bronze.erp_px_cat_g1v2;
    PRINT '>> Inserting Data Into: bronze.erp_px_cat_g1v2'
    BULK INSERT bronze.erp_px_cat_g1v2
    FROM '/var/opt/mssql/datasets/source_erp/px_cat_g1v2.csv'
    WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ','
    );
    SET @end_time = GETDATE();

    PRINT '>> Load Duration :' + CAST(DATEDIFF(SECOND, @start_time, @end_time) as NVARCHAR) + 'seconds'
    PRINT '----------------------------------------------'

    SET @batch_end_time = GETDATE();

    PRINT '>>Total Load Duration :' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) as NVARCHAR) + 'seconds'
    PRINT '----------------------------------------------'

    END TRY
    BEGIN CATCH
    PRINT '================================================================';
    PRINT 'ERROR OCCURED DURING LOADING THE BRONZE LAYER'    
    PRINT 'ERROR MESSAGE' + ERROR_MESSAGE();
    PRINT 'ERROR NUMBER ' + CAST(ERROR_NUMBER() AS NVARCHAR);
    PRINT '================================================================';

    END CATCH

END

EXEC bronze.load_bronze;
