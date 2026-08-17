/*
--------------------------------------------------------------------------------------------------------------------------------------
Quality Checks
--------------------------------------------------------------------------------------------------------------------------------------
Script Purpose:
This script performs various quality checks for data consistency, accuracy, and standardization across the 'silver' schemas. 
It includes checks for:
    - Null or duplicate primary keys.
    - Unwanted spaces in string fields.
    - Data standardization and consistency.
    - Invalid date ranges and orders.
    - Data consistency between related fields.
Usage Notes:
    - Run these checks after data loading Silver Layer.
    - Investigate and resolve any discrepancies found during the checks.
--------------------------------------------------------------------------------------------------------------------------------------

* /

--------------------------------------------------------------------------------------------------------------------------------------
-- Quality check for silver crm_cust_info tables


-- Check for nulls or duplicate in primary key
-- Expectation : No result

select 
    cst_id,
    count(*)
from Silver.crm_cust_info
group by cst_id 
having count(*) > 1 or cst_id is NULL

-- taking any duplicate cst_id and analyse



select * from (

select *,
ROW_NUMBER() over(partition by cst_id order by cst_create_date desc) as flag_last 
from Silver.crm_cust_info
)t
where flag_last = 1

-- check for extra unwanted spaces
-- expectation : No results

select cst_firstname
from Silver.crm_cust_info
where cst_firstname != TRIM(cst_firstname) -- good

select cst_lastname
from Silver.crm_cust_info
where cst_lastname != TRIM(cst_lastname) -- good
select *
from Silver.crm_cust_info
where cst_gndr != TRIM(cst_gndr) -- good

-- data standardization and consistency

select DISTINCT cst_id
from Silver.crm_cust_info

-------------------------------------------------------------------------------------------------
-- Quality check for silver.crm_prd_info tables

-- Check for nulls or duplicate in primary key
-- Expectation : No result

select 
    prd_id,
    count(*)
from silver.crm_prd_info
group by prd_id
having count(*) > 1 or prd_id is NULL -- good


--  where SUBSTRING(prd_key,7, LEN(prd_key)) in (
--     select distinct sls_prd_key from bronze.crm_sales_details )


-- check for extra unwanted spaces
-- expectation : No results

select prd_nm
from silver.crm_prd_info
where prd_nm != TRIM(prd_nm) -- good


-- check for extra negative values
-- expectation : No results


select prd_cost
from silver.crm_prd_info
where prd_cost < 0 OR prd_cost is null -- good

-- Data Standardization & consistency 

select distinct prd_line 
from silver.crm_prd_info --good

-- check for invalid data format

select 
    *
from silver.crm_prd_info
where prd_end_dt < prd_start_dt -- good

---------------------------------------------------------------------------------------------------------------------------------------
-- Quality Checks for silver.crm_sales_details 
-- where sls_ord_num != TRIM(sls_ord_num)

-- where sls_cust_id not in (
--     select cst_id from silver.crm_cust_info
-- )

-- where sls_prd_key not in (
--     select prd_key from silver.crm_prd_info
-- )

select * from silver.crm_prd_info
select * from Silver.crm_cust_info
select * from silver.crm_sales_details
  
--- Quality checks 
--check for invalid date

select  
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt
from silver.crm_sales_details
where sls_order_dt IS NULL OR
    sls_ship_dt IS NULL OR
    sls_due_dt IS NULL

-- check for order/ship/due date sequence...

-- Order date must be earlier than ship and due date

select  
    *
from silver.crm_sales_details
where sls_order_dt > sls_ship_dt or sls_order_dt > sls_due_dt

-- check for Data consistency : business logic btw sls, price, qty
-- Sales = price * qty
-- values must not be zero, negative or null 


select  
    sls_sales
    sls_quantity,
    sls_price 
from silver.crm_sales_details
where sls_quantity <= 0 or sls_quantity is NULL 


select  
    sls_sales,
    sls_price,
    sls_sales,
    sls_quantity,
    sls_price 

from silver.crm_sales_details
where sls_sales <= 0 or sls_sales is NULL 

----------------------------------------------------------------------------------------------------------------------------------------
-- Quality checks for silver.erp_cust_az12
-- check for primary id and foriegn id relation 

select 
    cid,
    bdate,
    gen
    from silver.erp_cust_az12
    where cid like 'NAS%' or cid is NULL


-- check for out of range birth dates


select 
    cid,
    bdate,
    gen
    from silver.erp_cust_az12
    where bdate < '1920-01-01' or bdate > GETDATE()

-- Data consistency and standardization

select distinct gen from silver.erp_cust_az12

select * from silver.erp_cust_az12

----------------------------------------------------------------------------------------------------------------------------------------
-- Quality check for silver.erp_loc_a101


select 
    cid
from silver.erp_loc_a101

-- data standardization and consistency

select distinct cntry
from silver.erp_loc_a101


----------------------------------------------------------------------------------------------------------------------------------------
-- Quality check for silver.erp_px_cat_g1v2
-- check for duplicates/NULLs standardization & consistency

select distinct maintenance
from silver.erp_px_cat_g1v2

-- Check for unwanted spaces

select 
    id,
    cat,
    subcat,
    maintenance
from silver.erp_px_cat_g1v2
where cat != TRIM(cat) or subcat != TRIM(subcat) or maintenance != TRIM(maintenance) -- good

