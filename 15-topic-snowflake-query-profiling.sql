
-- 15.0.0  TOPIC: Snowflake Query Profiling
--         The Query Profile, available through the Snowflake Web UI, provides
--         execution details for a query. For the selected query, it provides a
--         graphical representation of the main components of the processing
--         plan for the query, with statistics for each component, along with
--         details and statistics for the overall query.

-- 15.1.0  Using the Query Profile
--         Learn to use the Snowflake Query Profile to read the execution plan
--         of a query including the various SQL operations and performance
--         metrics.

-- 15.1.1  Navigate to Worksheets and create a new worksheet. Renamed the
--         worksheet to Query Profile.

-- 15.1.2  Set the following as as follows:

USE role training_role;
USE warehouse TOUCAN_QUERY_WH;
USE database snowflake_sample_data;
USE schema tpcds_sf10tcl;


-- 15.1.3  Run the query:
--         The query reports the total extended sales price per item brand of a
--         specific manufacturer (939) for all sales in a specific month of the
--         year (month 12).

ALTER SESSION SET USE_CACHED_RESULT = false;
ALTER WAREHOUSE TOUCAN_QUERY_WH SET WAREHOUSE_SIZE = 'X-LARGE';

SELECT  dt.d_year
       ,item.i_brand_id brand_id
       ,item.i_brand brand
       ,sum(ss_net_profit) sum_agg
FROM  date_dim dt
      ,store_sales
      ,item
WHERE dt.d_date_sk = store_sales.ss_sold_date_sk
  AND store_sales.ss_item_sk = item.i_item_sk
  AND item.i_manufact_id = 939
  AND dt.d_moy=12
GROUP BY
  dt.d_year,item.i_brand,item.i_brand_id
ORDER BY
  dt.d_year ,sum_agg desc, brand_id
LIMIT 100;


-- 15.2.0  Access the Query Profile

-- 15.2.1  In the Results section below the worksheet click on the Query ID link
--         when it appears:
--         Click on Query ID

-- 15.2.2  The following shows the query profile for the above query:
--         Query Profile Details
--         Some of the operation in this query graph display some pretty
--         impressive metrics that we will review in the next task.

-- 15.3.0  List Operator Nodes by Execution Time
--         A collapsible panel in the operator tree pane lists expensive nodes
--         by execution time in descending order, enabling users to locate
--         quickly the costliest operator nodes in terms of execution time.

-- 15.3.1  Click on the collapsible panel info and it displays only one
--         operator: TableScan [8].
--         The below operation had the longest execution time of all the nodes
--         depicted in the execution process.
--         Most Expensive Nodes

-- 15.4.0  Review the Operator Tree
--         The tree provides a graphical representation of the operator nodes
--         that comprise the query and the links that connect each operator.

-- 15.4.1  Examine the details of the table scan operation labeled TableScan[8]
--         by clicking on that node in the digram:
--         TableScan[8]: accessed the largest table, STORE_SALES.

-- 15.4.2  The partitioning pruning metric for this operator:
--         Partition scanned 51,590
--         Partition total 84.577
--         Partition Pruning Metrics

-- 15.5.0  Examine the Sort operation
--         SortWithLimit [1]

-- 15.5.1  Sort keys define the sorting order:
--         Sort With Limit

-- 15.5.2  Execution Time breaks down where the time was spent during the
--         processing of a query. These times are categorized and displayed in
--         the following order:

-- 15.5.3  Statistics provide a major source of information in the detail panel
--         which are grouped in the following sections:

