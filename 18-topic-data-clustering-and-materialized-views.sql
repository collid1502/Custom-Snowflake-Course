
-- 18.0.0  TOPIC: Data Clustering and Materialized Views

-- 18.1.0  Cluster a Table Using a Timestamp Column
--         Imagine having a weblog that keeps track of certain metrics that are
--         accessible by different attributes (IDs) for different use cases such
--         as a column like page id or a column like timestamp.

-- 18.1.1  Navigate to Worksheets and load the worksheet for this lab. You can
--         dran-n-drop it as well.

-- 18.1.2  Name the loaded worksheet Clustering & MV

-- 18.1.3  Set the worksheet context as follows:

USE ROLE TRAINING_ROLE;
USE DATABASE TOUCAN_DB ;
USE WAREHOUSE TOUCAN_QUERY_WH;
ALTER SESSION SET USE_CACHED_RESULT=TRUE;


-- 18.1.4  Create a table by cloning a table from the TRAINING_DB database

CREATE OR REPLACE TABLE TOUCAN_DB.PUBLIC.WEBLOG CLONE TRAINING_DB.TRAININGLAB.WEBLOG;

--         NOTE: The original WEBLOG table was generated with data from the
--         following query which you do not need to run:

-- No need to run this
/**
INSERT INTO WEBLOG SELECT
    (SEQ8())::BIGINT AS CREATE_MS ,
    UNIFORM(1,9999999,RANDOM(10002))::BIGINT PAGE_ID ,
    UNIFORM(1,9999999,RANDOM(10003))::INTEGER TIME_ON_LOAD_MS ,
    UNIFORM(1,9999999,RANDOM(10005))::INTEGER METRIC2 ,
    UNIFORM(1,9999999,RANDOM(10006))::INTEGER METRIC3 ,
    UNIFORM(1,9999999,RANDOM(10007))::INTEGER METRIC4 ,
    UNIFORM(1,9999999,RANDOM(10008))::INTEGER METRIC5 ,
    UNIFORM(1,9999999,RANDOM(10009))::INTEGER METRIC6 ,
    UNIFORM(1,9999999,RANDOM(10010))::INTEGER METRIC7 ,
    UNIFORM(1,9999999,RANDOM(10011))::INTEGER METRIC8 ,
    UNIFORM(1,9999999,RANDOM(10012))::INTEGER METRIC9 
FROM TABLE(GENERATOR(ROWCOUNT => 10000000000)) ORDER BY CREATE_ms;
**/


-- 18.1.5  Check the clustering quality of the column, CREATE_MS:

SELECT SYSTEM$CLUSTERING_INFORMATION( 'WEBLOG' , '(CREATE_MS)');


-- 18.1.6  Clustering information from the query above:

-- 18.1.7  Run the following query that incorporates a filter that uses column
--         CREATE_MS and review the query profile.

SELECT COUNT(*) CNT
     , AVG(TIME_ON_LOAD_MS) AVG_TIME_ON_LOAD
FROM WEBLOG
WHERE CREATE_MS BETWEEN 1000000000 AND 1000001000;


-- 18.1.8  View the query profile for the above query.
--         Note that the TableScan[2] operator, the partition pruning is very
--         good:
--         TableScan[2] Node Details

-- 18.1.9  Check for clustering on the other column, PAGE_ID. It is expected to
--         be poor.

SELECT SYSTEM$CLUSTERING_INFORMATION( 'WEBLOG' , '(PAGE_ID)' );


-- 18.1.10 Clustering information from the above query:

-- 18.1.11 Query performance is expected to be sub-optimal using the filter with
--         column PAGE_ID

SELECT COUNT(*) CNT
     , AVG(TIME_ON_LOAD_MS) AVG_TIME_ON_LOAD
FROM WEBLOG
WHERE PAGE_ID=100000; 


-- 18.1.12 Check the query profile of the above query. It should be observed
--         that the TableScan[2] operator, the partition pruning is rather poor
--         as it is performing a full table scan.
--         TableScan[2] Node Details

-- 18.2.0  Cluster a Table Using a PAGE_ID Column
--         Running both types of queries with equally good performance requires
--         using a second copy of the data that’s organized differently, hence
--         optimizing access for both query patterns.

-- 18.2.1  Create a Materialized View
--         Creating the materialized view with Snowflake allows us to specify
--         the new clustering key, which enables Snowflake to reorganize the
--         data during the initial creation of the materialized view. Note the
--         clause CLUSTER BY (PAGE_ID).
--         Note: This might take ~7 minutes. While the select off the base
--         table, WEBLOG, is not complex, Snowflake is creating micro-partitions
--         for the view data. This involves more I/O than a simple SELECT query.
--         Feel free to take a break while the query runs.

ALTER WAREHOUSE TOUCAN_QUERY_WH SET WAREHOUSE_SIZE = XLARGE;

CREATE OR REPLACE MATERIALIZED VIEW MV_TIME_ON_LOAD
    (CREATE_MS,
    PAGE_ID,
    TIME_ON_LOAD_MS)
    CLUSTER BY (PAGE_ID)
AS
SELECT
    CREATE_MS,
    PAGE_ID,
    TIME_ON_LOAD_MS
FROM WEBLOG;


-- 18.2.2  After completing the creation of the materialized view, validate
--         optimal data distribution by retrieving the clustering information,
--         by running the following query:

SELECT SYSTEM$CLUSTERING_INFORMATION ( 'MV_TIME_ON_LOAD' , '(PAGE_ID)' );


-- 18.2.3  Clustering informatoin form the query above:

-- 18.2.4  Scale down the warehouse from XLARGE to LARGE.

ALTER WAREHOUSE TOUCAN_QUERY_WH SET WAREHOUSE_SIZE = LARGE;


-- 18.2.5  Check the runtime for the same query against the new materialized
--         view using a smaller warehouse.
--         Prior testing showed the response time is similar to the lookup using
--         the CREATE_MS column against the base table. Your mileage might vary.

-- 18.2.6  Run the following query over the newly created materialized view,
--         MV_TIME_ON_LOAD:

SELECT COUNT(*), AVG(TIME_ON_LOAD_MS) AVG_TIME_ON_LOAD
FROM MV_TIME_ON_LOAD
WHERE PAGE_ID=100000;

--         This example illustrates a substantial improvement in terms of query
--         performance.

-- 18.2.7  Check the query profile. It should be observed that the TableScan[1]
--         operator, the partition pruning is very effective:

-- 18.2.8  Use the SHOW command to display information about the materialized
--         view created:

SHOW MATERIALIZED VIEWS ON WEBLOG;


