
-- 16.0.0  TOPIC: Best Practices for Writing High Performance Queries in
--         Snowflake
--         We submit SQL queries in order to interact with objects and their
--         data in the Snowflake database. Therefore, effective query
--         formulation and retrieval can have significant impact on query
--         performance which in turn optimizes compute usage and credit
--         consumption. This exercise will review examples of common query
--         constructs which will be the backdrop for evaluating query
--         performance. This is to help spot both best practices of designing
--         high performing SQL queries as well as typical issues in SQL query
--         expressions that may cause performance bottlenecks.

-- 16.1.0  Summary of Best Practices for High Performing SQL

-- 16.2.0  Provide Filters in Queries to Assist SQL Pruner for Reducing Data
--         Access I/O
--         Review performance benefits and implications of filter design to
--         identify the best practices

-- 16.2.1  Navigate to Worksheets and create a new worksheet and rename it to
--         Filter Design. Load the contents of the .sql file corresponding to
--         this lab into the worksheet via Load Worksheet or drag-n-drop.

-- 16.2.2  Run the following SQL to set context:

USE ROLE TRAINING_ROLE;
USE WAREHOUSE TOUCAN_QUERY_WH;
USE DATABASE TRAINING_DB;
USE SCHEMA TPCH_SF1000;

ALTER SESSION SET USE_CACHED_RESULT = FALSE;
ALTER WAREHOUSE TOUCAN_QUERY_WH SET WAREHOUSE_SIZE = 'X-LARGE';


-- 16.2.3  Run the following query to filter on the columns that are clustered
--         columns:

SELECT
  c_custkey,
  c_name,
  sum(l_extendedprice * (1 - l_discount)) as revenue, c_acctbal,
  n_name,
  c_address,
  c_phone,
  c_comment
FROM customer 
  inner join orders
    on c_custkey = o_custkey 
  inner join lineitem
    on l_orderkey = o_orderkey 
  inner join nation
    on c_nationkey = n_nationkey 
WHERE
  o_orderdate >= to_date('1993-10-01')
    AND o_orderdate < dateadd(month, 3, to_date('1993-10-01')) 
    AND l_returnflag = 'R'
GROUP BY
  c_custkey, 
  c_name, 
  c_acctbal, 
  c_phone, 
  n_name, 
  c_address, 
  c_comment
ORDER BY
  3 desc
LIMIT 20;


-- 16.2.4  Access the query profile after the execution completes.

-- 16.2.5  Click on the TableScan [4] node in the diagram as shown in the screen
--         capture below:
--         TableScan 4 Details

-- 16.2.6  Take note of the Pruning metrics:

-- 16.2.7  Observe the following items:

-- 16.2.8  Run a query to check the clustering quality of filter column,
--         O_ORDERDATE by running the command:

SELECT SYSTEM$CLUSTERING_INFORMATION( 'orders' , '(o_orderdate)' );

--         Review the result and notice that the table is fairly well clustered
--         around the O_ORDERDATE dimension
--         Review the following documentation:
--         https://docs.snowflake.com/en/user-guide/tables-clustering-
--         micropartitions.html#clustering-information-maintained-for-micro-
--         partitions

-- 16.2.9  Review the same query profile for the previous query.

-- 16.2.10 Click on the TableScan [6] node in the diagram as in the screenshot
--         below.
--         Take note of the Pruning metrics:

-- 16.2.11 Take note of the following observations:
--         TableScan 6 Details

-- 16.2.12 Run a query to check the clustering quality of filter column,
--         c_custkey by running the following command:

SELECT SYSTEM$CLUSTERING_INFORMATION( 'customer' , '(c_custkey)' );


-- 16.2.13 Examine the result and note that the table is poorly clustered around
--         the c_custkey dimension:
--         Revisit the documenation link cited above for more information
--         regarding clustering.
--         Identify the following best practices:

-- 16.3.0  Explore the Peformance of GROUP BY and ORDER BY Operations
--         Review performance benefits and implications GROUP BY column usage
--         scenarios to identify the best practices.
--         The following scenarios have more limited requirements on compute
--         resources, thereby contributing to faster query performance. - Group
--         by columns with the lowest cardinality (few distinct values) you can.
--         - Group by columns with correlation to the table’s clustering
--         columns. - Order by columns with lowest cardinality (few distinct
--         values) you can.

-- 16.3.1  GROUP BY with low cardinality columns

-- 16.3.2  Run the following query:

SELECT l_returnflag,
l_linestatus,
sum(l_quantity) as sum_qty,
sum(l_extendedprice) as sum_base_price,
sum(l_extendedprice * (1-l_discount)) as sum_disc_price,
sum(l_extendedprice * (1-l_discount) *
(1+l_tax)) as sum_charge,
avg(l_quantity) as avg_qty,
avg(l_extendedprice) as avg_price,
avg(l_discount) as avg_disc,
count(*) as count_order
FROM lineitem
WHERE l_shipdate <= dateadd(day, -90, to_date('1998-12-01'))
GROUP BY l_returnflag, l_linestatus
ORDER BY l_returnflag, l_linestatus;


-- 16.3.3  View the query profile and select the operator Aggregate [1].
--         Observe the following performance metrics for this operator:
--         Aggregate Node 1

-- 16.3.4  ORDER BY Performance Example

-- 16.3.5  View the same query profile as in the example above.

-- 16.3.6  Click on the operator Sort [4].
--         Observe the following performance metrics for this operator:
--         Sort Node 4
--         In the GROUP BY clause when using the column’s matching clustering
--         order the query optimizer can push down partition pruning for a
--         performance benefit.

-- 16.3.7  Run the following query:

SELECT l_shipdate, count( * ) FROM lineitem
GROUP BY 1
ORDER BY 1;


-- 16.3.8  Access the query profile after the execution completes

-- 16.3.9  Click on the TableScan [2] node in the diagram as shown in the
--         screenshot below.
--         Take note of the Pruning metrics:
--         Observe the following benefits:
--         Table Scan Node

-- 16.3.10 Check the clustering quality of filter column, L_SHIPDATE using the
--         following command:

SELECT SYSTEM$CLUSTERING_INFORMATION( 'lineitem' , '(l_shipdate)' );

--         Review the results:

-- 16.4.0  LIMIT Clauses
--         Applying a LIMIT clause to a query does not affect the amount of data
--         that is read. It simply limits the results set output.

-- 16.4.1  Use the LIMIT clause to limit the result set

-- 16.4.2  Execute the following query:

SELECT
S.SS_SOLD_DATE_SK,
R.SR_RETURNED_DATE_SK,
S.SS_STORE_SK,
S.SS_ITEM_SK,
S.SS_CUSTOMER_SK,
S.SS_TICKET_NUMBER,
S.SS_QUANTITY,
S.SS_SALES_PRICE,
S.SS_CUSTOMER_SK,
S.SS_STORE_SK,
S.SS_QUANTITY,
S.SS_SALES_PRICE,
R.SR_RETURN_AMT
FROM SNOWFLAKE_SAMPLE_DATA.TPCDS_SF10TCL.STORE_SALES  S
INNER JOIN SNOWFLAKE_SAMPLE_DATA.TPCDS_SF10TCL.STORE_RETURNS  R on R.SR_ITEM_SK=S.SS_ITEM_SK
WHERE  S.SS_ITEM_SK =4164
LIMIT 100;


-- 16.4.3  Review the query profile and select the Limit[1] node in the diagram
--         as in the screenshot below.
--         Limit Node 1

-- 16.4.4  Observe the following traits:

-- 16.4.5  Identify the best practices:

-- 16.5.0  Join Optimizations in Snowflake
--         Joins are one of the most resource-intensive operations. The
--         Snowflake optimizer provides built-in, dynamic partition pruning to
--         help reduce data access during join processing.

-- 16.5.1  Identify the following best practice

-- 16.6.0  Dynamic Partition Pruning Example

-- 16.6.1  Run the following query:

USE SCHEMA snowflake_sample_data.tpcds_sf10tcl;

SELECT count(ss_customer_sk) 
FROM store_sales JOIN date_dim d
ON ss_sold_date_sk = d_date_sk
WHERE d_year = 2000
GROUP BY ss_customer_sk;


-- 16.6.2  View the query profile and select the TableScan [4] node in the
--         diagram as in the screenshot below.
--         Table Scan Node 4

-- 16.6.3  Take note of the performance metrics for this operator:

-- 16.6.4  Observe the following conditions:

-- 16.6.5  Check the clustering quality of predicate column SS_SOLD_DATE_SK in
--         STORE_SALES table using the following command:

SELECT SYSTEM$CLUSTERING_INFORMATION( 'snowflake_sample_data.tpcds_sf10tcl.store_sales', '(ss_sold_date_sk)');


-- 16.6.6  Review the result:

