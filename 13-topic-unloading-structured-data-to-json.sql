
-- 13.0.0  TOPIC: Unloading Structured Data to JSON
--         In this exercise, you will use the object_construct() function to
--         transform the structured REGION table data into JSON format, unload
--         it to a JSON file in the internal stage, and download the file to
--         your local machine.

-- 13.1.0  Unload the REGION table to JSON

-- 13.1.1  Using SnowSQL, login to the class Snowflake account
--         Your instructor may have already shown you how to access the SnowSQL
--         available on our notebook server. If you have already logged into
--         https://labs.snowflakeuniversity.com you may do this this step via
--         the cloud OR else locally if you have SnowSQL installed on your
--         machine.
--         snowsql -a  [account] - u TOUCAN

-- 13.1.2  Enter your password when prompted in SnowSQL and hit enter.

-- 13.1.3  Execute the following using SnowSQL to set the context:

USE ROLE training_role;
USE DATABASE TOUCAN_db;
USE SCHEMA PUBLIC;
USE WAREHOUSE TOUCAN_LOAD_WH;


-- 13.1.4  Run a query to evaluate all records in the REGION table in your
--         TOUCAN_DB in the PUBLIC schema.

-- 13.1.5  Confirm the table has five rows.

select count(*) from TOUCAN_DB.public.region;


-- 13.1.6  Optional: If the REGION table is empty, reload it from the region.tbl
--         file (see details in data loading lab).

COPY INTO TOUCAN_DB.public.region
FROM @TRAINING_DB.TRAININGLAB.ED_STAGE/load/lab_files/
FILES = ( 'region.tbl' )
FILE_FORMAT = ( FORMAT_NAME = TRAINING_DB.TRAININGLAB.MYPIPEFORMAT );


-- 13.2.0  Unload the REGION Table into JSON Format to an Internal Stage.

COPY INTO @%region/TOUCAN_json_region
FROM (select object_construct(*) from TOUCAN_DB.public.region)
FILE_FORMAT = ( TYPE = JSON COMPRESSION = NONE );

--         NOTE: Remember to name the unload file with a unique prefix –
--         TOUCAN.

-- 13.2.1  Confirm your file has been created in the internal table stage.

-- 13.2.2  You should see your *TOUCAN_json_region* file listed:

list @%region;


-- 13.2.3  Use the GET command to download the *TOUCAN_json_region* file from
--         the internal table stage to your local machine.
--         Supply a path to a local directory on your machine if using SnowSQL
--         locally or, if using Jupyter Labs, an appropriate path on the cloud
--         machine. For example, use the following syntax as a template:
--         file:///home/jovyan. Make sure that you use the appropriate commands
--         to set your session context such as database, role, warehouse, etc.

-- From SnowSQL - does not work from a worksheet in the Snowflake UI
GET @%region file:///home/jovyan;


-- 13.2.4  Open the file in a text editor.

-- 13.2.5  Confirm the structured REGION table data has been transformed to the
--         specified semi-structured format.

-- 13.3.0  Exporting directly from the Snowflake Web UI
--         For small datasets (less than 100MB) you can export query results
--         from the Snowflake Web UI. While not suitable for large datasets or a
--         diverse set of file formats, you can export the results of any query
--         displayed in the UI results pane for queries for which you can view
--         the results (i.e., queries you’ve executed, and where the query
--         result is still available).
--         Note also that only the following file formats are supported for the
--         Export Result option, so it is not possible to output semi-structured
--         data in its native format this way:
--         Comma-separated values (CSV)
--         Tab-separated values (TSV)

-- 13.3.1  Optional: Export and download results via the Snowflake Web UI
--         Try it out. Run a query to get results you want to export displayed
--         in the Results pane in the Snowflake Web UI, then click the Download
--         or View Results button to get a downloaded copy of those results.
--         Export Using The Snowflake Web UI

