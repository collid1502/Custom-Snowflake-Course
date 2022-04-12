
-- 12.0.0  TOPIC: Loading Data in Bulk
--         In this exercise you will learn how to load data into Snowflake using
--         external stages and various file formats.

-- 12.1.0  Loading Structured Data with the UI

-- 12.1.1  Load File Format & Create Table SQL Statements
--         This exercise will load the file region.tbl into a REGION table in
--         your database. The region.tbl file is pipe (|) delimited. It has no
--         header and contains the following five rows:
--         NOTE: In the region.tbl file there is a delimiter at the end of every
--         line, which, by default, is interpreted as an additional column by
--         the copy into a statement.

-- 12.1.2  Start a new worksheet.
--         Set the worksheet context to use your warehouse, database, the PUBLIC
--         schema, and the role TRAINING_ROLE.

-- 12.1.3  Navigate to Worksheets and create a new worksheet. Name it Data
--         Movement.

-- 12.1.4  Set the worksheet context

USE ROLE TRAINING_ROLE;
USE WAREHOUSE TOUCAN_LOAD_WH;
USE database TOUCAN_DB;
USE SCHEMA PUBLIC;


-- 12.1.5  Create the REGION table

CREATE OR REPLACE TABLE REGION (
       R_REGIONKEY NUMBER(38,0) NOT NULL,
       R_NAME      VARCHAR(25)  NOT NULL,
       R_COMMENT   VARCHAR(152)
);


-- 12.1.6  Confirm the region.tbl file is in the external stage using the LIST
--         command:

LIST @TRAINING_DB.TRAININGLAB.ED_STAGE/load/lab_files/ pattern='.*region.*';

COPY INTO REGION
  FROM @TRAINING_DB.TRAININGLAB.ED_STAGE/load/lab_files/
 FILES = ( 'region.tbl' )
 FILE_FORMAT = ( FORMAT_NAME = TRAINING_DB.TRAININGLAB.MYPIPEFORMAT );

--         NOTE: Loading the data into the REGION table from the stage you need
--         to use a FILE FORMAT object. If a named FILE FORMAT object does not
--         exist it is necessary to describe the properties of the files
--         manually within the COPY INTO statement. In this case, the last line
--         of the code above will be transformed to the following:

-- Not intended to be executed
-- FILE_FORMAT = ( TYPE = CSV
-- COMPRESSION = NONE
-- FIELD_DELIMITER = '|'
-- FILE_EXTENSION = 'tbl'
-- ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE );


-- 12.1.7  Select and review the data in the REGION table, either by executing
--         the following command in your worksheet or by using the left-hand
--         sidebar:

SELECT * FROM REGION;


-- 12.1.8  Click on your database TOUCAN_DB

-- 12.1.9  Click on the PUBLIC schema

-- 12.1.10 Click on Tables

-- 12.1.11 Click on the series of three ellipses on the REGION table and select
--         **Preview Data*.
--         Sidebar View

-- 12.2.0  Loading Semi-Structured Data

-- 12.2.1  This exercise will load a Parquet data file using different
--         approaches.

-- 12.2.2  Empty the rows of the REGION table that is in the PUBLIC schema of
--         your TOUCAN_DB database:

TRUNCATE TABLE REGION;


-- 12.2.3  Confirm that the region.parquet file is in the external stage:

list @TRAINING_DB.TRAININGLAB.ED_STAGE/load/lab_files pattern = '.*region.*';


-- 12.2.4  Create a FILE FORMAT object for Parquet files in the current schema:

CREATE OR REPLACE FILE FORMAT MYPARQUETFORMAT
TYPE = PARQUET
COMPRESSION = NONE;


-- 12.2.5  Query the data in the region.parquet file from its stage location:

SELECT
  $1,
  $1:_COL_0::number,
  $1:_COL_1::varchar,
  $1:_COL_2::varchar
FROM @TRAINING_DB.TRAININGLAB.ED_STAGE/load/lab_files/region.parquet
(FILE_FORMAT => MYPARQUETFORMAT);


-- 12.2.6  Reload the REGION table from the region.parquet file:

COPY INTO REGION FROM (
SELECT $1:_COL_0::number,
$1:_COL_1::varchar,
$1:_COL_2::varchar
FROM @TRAINING_DB.TRAININGLAB.ED_STAGE/load/lab_files/region.parquet )
FILE_FORMAT = (FORMAT_NAME = MYPARQUETFORMAT);


-- 12.2.7  View the data:

SELECT * FROM REGION;

--         Documentation: https://docs.snowflake.com/en/user-guide/script-data-
--         load-transform-parquet.html#script-loading-and-unloading-parquet-data

-- 12.3.0  Loading a JSON Data File

-- 12.3.1  Confirm that the countrygeo.json file is in the external stage:

list @TRAINING_DB.TRAININGLAB.ED_STAGE pattern = '.*countrygeo.*';


-- 12.3.2  Load the COUNTRYGEO table from the countrygeo.json file.

create or replace TABLE COUNTRYGEO (
       CG_NATIONKEY NUMBER(38,0),
       CG_CAPITAL   VARCHAR(100),
       CG_LAT       NUMBER(20,10),
       CG_LON       NUMBER(20,10),
       CG_ALTITUDE  NUMBER(38,0)
);

COPY INTO COUNTRYGEO ( cg_nationkey, cg_capital,cg_lat, cg_lon, cg_altitude)
FROM ( select parse_json($1):cg_nationkey,
parse_json($1):cg_capital,
parse_json($1):cg_coord.cg_lat,
parse_json($1):cg_coord.cg_lon,
parse_json($1):cg_altitude
FROM @TRAINING_DB.TRAININGLAB.ED_STAGE/load/lab_files/countrygeo.json )
FILE_FORMAT = ( FORMAT_NAME = TRAINING_DB.TRAININGLAB.MYJSONFORMAT )
ON_ERROR = 'continue';


-- 12.3.3  View the data:

SELECT * FROM COUNTRYGEO;

--         Documentation: https://docs.snowflake.com/en/user-guide/json-basics-
--         tutorial.html

-- 12.4.0  Loading With More Options

-- 12.4.1  Detect data file format problems using VALIDATION_MODE
--         This exercise will use Snowflake’s VALIDATION_MODE option with a COPY
--         INTO statement to demonstrate Snowflake’s pre-load error detection
--         mechanism. The information returned by this functionality can be very
--         helpful in determining how to set FILE FORMAT parameters. For this
--         exercise you should use the load warehouse.
--         Documentation: https://docs.snowflake.com/en/sql-reference/sql/copy-
--         into-table.html#validating-staged-files

-- 12.4.2  Empty the REGION table in the PUBLIC schema of your TOUCAN_DB
--         database.

TRUNCATE TABLE REGION;


-- 12.4.3  Run a COPY command with VALIDATION_MODE set against region_bad_1.tbl
--         from the @TRAINING_DB.TRAININGLAB.FUNDAMENTALS_LAB stage into the
--         REGION table and identify the issue that will cause the load to fail.
--         region_bad_1.tbl contents:

-- 12.4.4  Run the following copy command with VALIDATION_MODE and note the
--         error:

COPY INTO REGION FROM @TRAINING_DB.TRAININGLAB.ED_STAGE/load/lab_files/
 FILES = ( 'region_bad_1.tbl' )
 FILE_FORMAT = ( FORMAT_NAME = TRAINING_DB.TRAININGLAB.MYPIPEFORMAT )
 VALIDATION_MODE = RETURN_ALL_ERRORS;

--         NOTE: The COPY INTO command will fail because of the data type
--         mismatch in the second line of the data file.

-- 12.4.5  Run a COPY INTO command in VALIDATION_MODE against region_bad_2.tbl
--         from the @TRAINING_DB.TRAININGLAB.FUNDAMENTALS_LAB stage into the
--         REGION table and identify the issue that will cause the load to fail.
--         region_bad_2.tbl contents:

-- 12.4.6  Run the following COPY INTO command with VALIDATION_MODE and note the
--         error:

COPY INTO REGION FROM @TRAINING_DB.TRAININGLAB.ED_STAGE/load/lab_files/
  FILES = ( 'region_bad_2.tbl' )
  FILE_FORMAT = ( FORMAT_NAME = TRAINING_DB.TRAININGLAB.MYPIPEFORMAT )
  VALIDATION_MODE = RETURN_ALL_ERRORS;

--         NOTE: The COPY INTO command will fail of the missing pipe after the
--         name in the third line of the data file.

-- 12.4.7  Load Data with ON_ERROR Options Set to Continue
--         This exercise will use Snowflake’s optional ON_ERROR parameter in the
--         COPY INTO command to define the behavior Snowflake should exhibit if
--         an error is encountered when loading a file.
--         Documentation: https://docs.snowflake.com/en/sql-reference/sql/copy-
--         into-table.html#copy-into-table

-- 12.4.8  Run a COPY INTO command in with the ON_ERROR parameter set to
--         CONTINUE against region_bad_1.tbl from the
--         @TRAINING_DB.TRAININGLAB.FUNDAMENTALS_LAB stage into the REGION
--         table.

-- 12.4.9  Note the output:

COPY INTO REGION FROM @TRAINING_DB.TRAININGLAB.ED_STAGE/load/lab_files/
  FILES = ( 'region_bad_1.tbl' )
  FILE_FORMAT = ( FORMAT_NAME = TRAINING_DB.TRAININGLAB.MYPIPEFORMAT )
ON_ERROR = CONTINUE;


-- 12.4.10 View the data that was loaded and confirm that all rows were loaded
--         except the row that the validation mode against this file stated
--         would not load:

SELECT * FROM REGION;


-- 12.4.11 Empty the REGION table in the PUBLIC schema of your TOUCAN_DB
--         database.

TRUNCATE TABLE REGION;


-- 12.4.12 Run a COPY INTO command with the ON_ERROR parameter set to CONTINUE
--         against file region_bad_2.tbl from the
--         @TRAINING_DB.TRAININGLAB.FUNDAMENTALS_LAB stage into the REGION
--         table. Note the output:

COPY INTO REGION FROM @TRAINING_DB.TRAININGLAB.ED_STAGE/load/lab_files/
  FILES = ( 'region_bad_2.tbl' )
  FILE_FORMAT = ( FORMAT_NAME = TRAINING_DB.TRAININGLAB.MYPIPEFORMAT )
ON_ERROR = CONTINUE;


-- 12.4.13 View the data that was loaded and confirm that all rows were loaded
--         except the row the validation mode against this file stated would not
--         load:

SELECT * FROM REGION;


-- 12.4.14 Reload theREGION table with clean data.

-- 12.4.15 Empty the REGION table in the PUBLIC schema of your TOUCAN_DB
--         database.

TRUNCATE TABLE REGION;


-- 12.4.16 Load the data from the internal table stage to the REGION table:

COPY INTO REGION FROM @TRAINING_DB.TRAININGLAB.ED_STAGE/load/lab_files/
  FILES = ( 'region.tbl' )
  FILE_FORMAT = ( FORMAT_NAME = TRAINING_DB.TRAININGLAB.MYPIPEFORMAT );


-- 12.4.17 View the data that was loaded and confirm that all 5 rows were
--         loaded.

SELECT * FROM REGION;


-- 12.4.18 Navigate to view in the Snowflake Web UI labeled Databases.

-- 12.4.19 Select your TOUCAN_DB database and confirm that every table has data
--         loaded.
--         Check Data Loaded

