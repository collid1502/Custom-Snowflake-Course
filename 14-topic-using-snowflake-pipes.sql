
-- 14.0.0  TOPIC: Using Snowflake Pipes
--         There are two types of Snowpipes; basic pipes and continuous load
--         pipes. In this exercise you will work with basic pipes.

-- 14.1.0  Setup a Basic Snowpipe Lab

-- 14.1.1  Set your context and create the CITIBIKE schema:

USE ROLE training_role;
USE WAREHOUSE TOUCAN_query_wh;
USE DATABASE TOUCAN_db;
CREATE SCHEMA IF NOT EXISTS citibike;
USE SCHEMA citibike;


-- 14.1.2  Create the CITIBIKE.TRIPS table:

create or replace table trips (
  tripduration integer
  ,starttime timestamp
  ,stoptime timestamp
  ,start_station_id integer
  ,start_station_name string
  ,start_station_latitude float
  ,start_station_longitude float
  ,end_station_id integer
  ,end_station_name string
  ,end_station_latitude float
  ,end_station_longitude float
  ,bikeid integer
  ,membership_type string
  ,usertype string
  ,birth_year integer
  ,gender integer);


-- 14.1.3  Create a pipe for the CITIBIKE.TRIPS table and the verify the pipe
--         exist:

CREATE OR REPLACE PIPE TOUCAN_db.citibike.trips_pipe  AS
  COPY INTO TOUCAN_DB.citibike.trips
    FROM
    (
      SELECT *
      FROM @TRAINING_DB.TRAININGLAB.CLASS_STAGE/COURSE/ADVANCED/TOUCAN
    )
    FILE_FORMAT=(FORMAT_NAME=training_db.traininglab.MYGZIPPIPEFORMAT);

SHOW PIPES;


-- 14.1.4  Dump data from existing CITIBIKE database onto the stage referenced
--         when creating the pipe:

COPY INTO @TRAINING_DB.TRAININGLAB.CLASS_STAGE/COURSE/ADVANCED/TOUCAN/citibike1_
FROM
  (
    SELECT *
    FROM CITIBIKE.SCHEMA1.TRIPS SAMPLE(10 ROWS)
  )
  FILE_FORMAT = (FORMAT_NAME = training_db.traininglab.MYGZIPPIPEFORMAT);


-- 14.1.5  List the files on the cloud storage stage managed by Snowflake (a.k.a
--         internal stage):

ls @TRAINING_DB.TRAININGLAB.CLASS_STAGE/COURSE/ADVANCED/TOUCAN;

--         You should see new files loaded onto the stage location specified in
--         the copy statement.

-- 14.1.6  Refresh the stage with rows and check the data before and after
--         loading it:

COPY INTO @TRAINING_DB.TRAININGLAB.CLASS_STAGE/COURSE/ADVANCED/TOUCAN/citibike2_
  FROM  (SELECT *  FROM CITIBIKE.SCHEMA1.TRIPS SAMPLE(10 ROWS))
   FILE_FORMAT = (FORMAT_NAME = training_db.traininglab.MYGZIPPIPEFORMAT);

ALTER PIPE TOUCAN_db.citibike.trips_pipe REFRESH;


-- 14.1.7  Stage more data onto the internal stage and refresh the pipe:

COPY INTO @TRAINING_DB.TRAININGLAB.CLASS_STAGE/COURSE/ADVANCED/TOUCAN/citibike3_
  FROM  (SELECT *  FROM CITIBIKE.SCHEMA1.TRIPS SAMPLE(10 ROWS))
   FILE_FORMAT = (FORMAT_NAME = training_db.traininglab.MYGZIPPIPEFORMAT);

ALTER PIPE TOUCAN_db.citibike.trips_pipe REFRESH;


-- 14.1.8  List files in the stage:

ls @TRAINING_DB.TRAININGLAB.CLASS_STAGE/COURSE/ADVANCED/TOUCAN;


-- 14.1.9  Query the table to see the freshly loaded data (this might take a few
--         minutes):

SELECT * FROM trips;


-- 14.1.10 Check load history:

SELECT *
FROM TABLE(information_schema.copy_history(table_name=>'trips', start_time=> dateadd(hours, -1, current_timestamp())));


