
-- 4.0.0   Review the Query Profile
--         Expect this lab to take approximately 15 minutes.

-- 4.1.0   Run the first explain plan

-- 4.1.1   Navigate to [Worksheets] and create a new worksheet named Query
--         Profile.

-- 4.1.2   Set the worksheet context as follows:

-- 4.1.3   Alternatively, execute the following SQL:

USE ROLE TRAINING_ROLE;
CREATE WAREHOUSE IF NOT EXISTS TOUCAN_WH;
ALTER WAREHOUSE TOUCAN_WH SET WAREHOUSE_SIZE = xsmall;
USE SNOWFLAKE_SAMPLE_DATA.TPCDS_SF10TCL;


-- 4.1.4   Disable the query result cache:

ALTER SESSION SET USE_CACHED_RESULT=FALSE;


-- 4.1.5   Run an explain plan on the sample query with a LIMIT:

EXPLAIN
SELECT c_customer_sk,
        c_customer_id, 
        c_last_name, 
        (ca_street_number || ' ' || ca_street_name),
        ca_city,  ca_state  
    FROM customer, customer_address
    WHERE c_customer_id = ca_address_id
    AND c_customer_sk between 100000 and 600000
    ORDER BY ca_city, ca_state
    LIMIT 10;


-- 4.1.6   Examine the explain plan

-- 4.2.0   Run the same query without the explain plan

-- 4.2.1   Run the SQL below:

SELECT c_customer_sk,
        c_customer_id, 
        c_last_name, 
        (ca_street_number || ' ' || ca_street_name),
        ca_city,  ca_state  
    FROM customer, customer_address
    WHERE c_customer_id = ca_address_id
    AND c_customer_sk between 100000 and 600000
    ORDER BY ca_city, ca_state
    LIMIT 10;


-- 4.3.0   Perform a Review of the Query Profile

-- 4.3.1   In the worksheet in the Results section click Query ID.

-- 4.3.2   Once the ID shows, click on it; the detail page for the query is
--         displayed:
--         Query Id Details

-- 4.3.3   Click the profile tab and review the Query Profile:

-- 4.3.4   Navigate back to the worksheet.

-- 4.4.0   Run an explain plan on the query without the limit

-- 4.4.1   Run the SQL below:

EXPLAIN
SELECT c_customer_sk,
        c_customer_id, 
        c_last_name, 
        (ca_street_number || ' ' || ca_street_name),
        ca_city,  ca_state  
    FROM customer, customer_address
    WHERE c_customer_id = ca_address_id
    AND c_customer_sk between 100000 and 600000
    ORDER BY ca_city, ca_state;


-- 4.4.2   Compare this plan to the one created above.

-- 4.5.0   Run the same query without the limit or the explain plan

-- 4.5.1   Run the SQL below:

SELECT c_customer_sk,
        c_customer_id, 
        c_last_name, 
        (ca_street_number || ' ' || ca_street_name),
        ca_city,  ca_state  
    FROM customer, customer_address
    WHERE c_customer_id = ca_address_id
    AND c_customer_sk between 100000 and 600000
    ORDER BY ca_city, ca_state;


-- 4.5.2   Open the query profile for this.

-- 4.5.3   Navigate to [History]. You should see the query you just ran at the
--         top of the table.

-- 4.5.4   Click on another query ID from the list - this is another way to get
--         the query profile page.

-- 4.5.5   View the profile for the query you selected.

-- 4.5.6   Run some additional queries on your own or select other queries from
--         the [History] table, and view the query results.
