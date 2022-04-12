
-- 9.0.0   Determine Appropriate Warehouse Sizes

-- 9.1.0   Run a sample query with an extra small warehouse
--         In this task you will disable the query result cache, and run the
--         same query on different sized warehouses to determine which is the
--         best size for the query. You will suspend your warehouse after each
--         test, to clear the data cache so the performance of the next query is
--         not artificially enhanced.
--         Expect this lab to take approximately 15 minutes.

-- 9.1.1   Navigate to [Worksheets].

-- 9.1.2   Create a new worksheet named Warehouse Sizing with the following
--         context:

USE ROLE TRAINING_ROLE;
CREATE WAREHOUSE IF NOT EXISTS TOUCAN_WH;
USE SNOWFLAKE_SAMPLE_DATA.TPCDS_SF10TCL;


-- 9.1.3   Change the size of your warehouse to Xsmall:

ALTER WAREHOUSE TOUCAN_WH
SET WAREHOUSE_SIZE = XSmall;


-- 9.1.4   Suspend and resume the warehouse to make sure its Data Cache is
--         empty, disable the query result cache and set a query tag:

ALTER WAREHOUSE TOUCAN_WH SUSPEND;
ALTER WAREHOUSE TOUCAN_WH RESUME;
ALTER SESSION SET USE_CACHED_RESULT = FALSE;
ALTER SESSION SET QUERY_TAG = 'TOUCAN_WH_Sizing';


-- 9.1.5   Run the following query (your test query - it will be used throughout
--         this task) to list detailed catalog sales data together with a
--         running sum of sales price within the order (it will take several
--         minutes to run):

SELECT cs_bill_customer_sk, cs_order_number, i_product_name, cs_sales_price, SUM(cs_sales_price)
OVER (PARTITION BY cs_order_number
   ORDER BY i_product_name
   ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) run_sum
FROM catalog_sales, date_dim, item
WHERE cs_sold_date_sk = d_date_sk
AND cs_item_sk = i_item_sk
AND d_year IN (2000) AND d_moy IN (1,2,3,4,5,6)
LIMIT 100;


-- 9.1.6   View the query profile, and click on the operator WindowFunction[1].

-- 9.1.7   Take note of the performance metrics for this operator: you should
--         see significant spilling to local storage, and possibly spilling to
--         remote storage.

-- 9.1.8   Take note of the performance on the small warehouse.
--         Warehouse Performance

-- 9.2.0   Run a sample query with a medium warehouse

-- 9.2.1   Suspend your warehouse, change its size to Medium, and resume it:

ALTER WAREHOUSE TOUCAN_WH SUSPEND;
ALTER WAREHOUSE TOUCAN_WH SET WAREHOUSE_SIZE = Medium;
ALTER WAREHOUSE TOUCAN_WH RESUME;


-- 9.2.2   Re-run the test query:

SELECT cs_bill_customer_sk, cs_order_number, i_product_name, cs_sales_price, SUM(cs_sales_price)
OVER (PARTITION BY cs_order_number
   ORDER BY i_product_name
   ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) run_sum
FROM catalog_sales, date_dim, item
WHERE cs_sold_date_sk = d_date_sk
AND cs_item_sk = i_item_sk
AND d_year IN (2000) AND d_moy IN (1,2,3,4,5,6)
LIMIT 100;


-- 9.2.3   View the query profile, and click the operator WindowFunction[1].

-- 9.2.4   Take note of the performance metrics for this operator. You should
--         see lower amounts spilling to local storage and remote disk, as well
--         as faster execution.

-- 9.3.0   Run a sample query with a large warehouse

-- 9.3.1   Suspend your warehouse, change its size to Large, and resume it:

ALTER WAREHOUSE TOUCAN_WH SUSPEND;
ALTER WAREHOUSE TOUCAN_WH SET WAREHOUSE_SIZE = Large;
ALTER WAREHOUSE TOUCAN_WH RESUME;


-- 9.3.2   Re-run the test query:

SELECT cs_bill_customer_sk, cs_order_number, i_product_name, cs_sales_price, SUM(cs_sales_price)
OVER (PARTITION BY cs_order_number
   ORDER BY i_product_name
   ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) run_sum
FROM catalog_sales, date_dim, item
WHERE cs_sold_date_sk = d_date_sk
AND cs_item_sk = i_item_sk
AND d_year IN (2000) AND d_moy IN (1,2,3,4,5,6)
LIMIT 100;


-- 9.3.3   Take note of the performance metrics for this operator. You will see
--         that there is no spilling to local or remote storage.

-- 9.4.0   Run a sample query with an extra large warehouse

-- 9.4.1   Suspend the warehouse, change it to XLarge in size, and resume it:

ALTER WAREHOUSE TOUCAN_WH SUSPEND;
ALTER WAREHOUSE TOUCAN_WH SET WAREHOUSE_SIZE = XLarge;
ALTER WAREHOUSE TOUCAN_WH RESUME;


-- 9.4.2   Re-run the test query.

SELECT cs_bill_customer_sk, cs_order_number, i_product_name, cs_sales_price, SUM(cs_sales_price)
OVER (PARTITION BY cs_order_number
   ORDER BY i_product_name
   ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) run_sum
FROM catalog_sales, date_dim, item
WHERE cs_sold_date_sk = d_date_sk
AND cs_item_sk = i_item_sk
AND d_year IN (2000) AND d_moy IN (1,2,3,4,5,6)
LIMIT 100;


-- 9.4.3   Note the performance.

-- 9.4.4   Suspend your warehouse, and change its size to XSmall:

ALTER WAREHOUSE TOUCAN_WH SUSPEND;
ALTER WAREHOUSE TOUCAN_WH SET WAREHOUSE_SIZE = XSmall;


-- 9.5.0   Run a query showing the query history results for these performance
--         tests

SELECT query_id,query_text, warehouse_size,(execution_time / 1000) Time_in_seconds, partitions_total, partitions_scanned,
        bytes_spilled_to_local_storage, bytes_spilled_to_remote_storage, query_load_percent
FROM "SNOWFLAKE"."ACCOUNT_USAGE"."QUERY_HISTORY" 
WHERE  query_tag = 'TOUCAN_WH_Sizing' 
AND WAREHOUSE_SIZE IS NOT NULL
AND QUERY_TYPE LIKE 'SELECT' ORDER BY start_time DESC;

