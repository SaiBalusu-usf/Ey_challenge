/*******************************************************************************
 * Network Operations Reporting and Analytics with Snowflake Intelligence
 * Setup Script
 * 
 * This script creates all necessary Snowflake objects for the Network Operations
 * solution including database, schemas, tables, stages, and warehouses.
 ******************************************************************************/

-- =============================================================================
-- SECTION 1: WAREHOUSES
-- =============================================================================
USE ROLE ACCOUNTADMIN;

CREATE WAREHOUSE IF NOT EXISTS NETWORK_OPS_WH
    WAREHOUSE_SIZE = 'SMALL'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE
    COMMENT = 'Warehouse for Network Operations queries and dashboard';

CREATE WAREHOUSE IF NOT EXISTS NETWORK_OPS_BUILD_WH
    WAREHOUSE_SIZE = 'MEDIUM'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE
    COMMENT = 'Warehouse for data loading operations';

-- =============================================================================
-- SECTION 2: DATABASE AND SCHEMAS
-- =============================================================================
CREATE DATABASE IF NOT EXISTS NETWORK_OPERATIONS
    COMMENT = 'Network Operations Reporting and Analytics Database';

USE DATABASE NETWORK_OPERATIONS;

-- Create schemas for different network domains
CREATE SCHEMA IF NOT EXISTS RAN_4G COMMENT = '4G Radio Access Network data';
CREATE SCHEMA IF NOT EXISTS RAN_5G COMMENT = '5G Radio Access Network data';
CREATE SCHEMA IF NOT EXISTS CORE_4G COMMENT = '4G Core Network data (EPC)';
CREATE SCHEMA IF NOT EXISTS CORE_5G COMMENT = '5G Core Network data (5GC)';
CREATE SCHEMA IF NOT EXISTS TRANSPORT COMMENT = 'Transport network data (backhaul/fronthaul)';
CREATE SCHEMA IF NOT EXISTS ANALYTICS COMMENT = 'Aggregated analytics and dimension tables';
CREATE SCHEMA IF NOT EXISTS STAGING COMMENT = 'Data staging area';

-- =============================================================================
-- SECTION 3: STAGES
-- =============================================================================
USE SCHEMA STAGING;

CREATE STAGE IF NOT EXISTS CSV_DATA
    DIRECTORY = (ENABLE = TRUE)
    COMMENT = 'Stage for CSV data files';

CREATE STAGE IF NOT EXISTS STREAMLIT_STAGE
    DIRECTORY = (ENABLE = TRUE)
    COMMENT = 'Stage for Streamlit application files';

-- =============================================================================
-- SECTION 4: FILE FORMAT
-- =============================================================================
CREATE FILE FORMAT IF NOT EXISTS CSV_FORMAT
    TYPE = 'CSV'
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    NULL_IF = ('NULL', 'null', '')
    EMPTY_FIELD_AS_NULL = TRUE;

-- =============================================================================
-- SECTION 5: DIMENSION TABLES
-- =============================================================================
USE SCHEMA ANALYTICS;

-- Cell Site Dimension
CREATE TABLE IF NOT EXISTS DIM_CELL_SITE (
    CELL_ID VARCHAR(50) PRIMARY KEY,
    SITE_NAME VARCHAR(100),
    REGION VARCHAR(50),
    CITY VARCHAR(100),
    NETWORK_TYPE VARCHAR(20),
    VENDOR VARCHAR(50),
    LOCATION_LAT FLOAT,
    LOCATION_LON FLOAT,
    ANTENNA_HEIGHT_M FLOAT,
    SECTOR_COUNT INTEGER,
    CAPACITY_MBPS FLOAT,
    INSTALL_DATE DATE,
    STATUS VARCHAR(20)
);

-- Network Element Dimension
CREATE TABLE IF NOT EXISTS DIM_NETWORK_ELEMENT (
    ELEMENT_ID VARCHAR(50) PRIMARY KEY,
    ELEMENT_NAME VARCHAR(100),
    ELEMENT_TYPE VARCHAR(50),
    NETWORK_DOMAIN VARCHAR(20),
    VENDOR VARCHAR(50),
    SOFTWARE_VERSION VARCHAR(50),
    CAPACITY FLOAT,
    REGION VARCHAR(50),
    STATUS VARCHAR(20)
);

-- =============================================================================
-- SECTION 6: FACT TABLES
-- =============================================================================

-- RAN Performance Facts (aggregated)
CREATE TABLE IF NOT EXISTS FACT_RAN_PERFORMANCE (
    TIMESTAMP TIMESTAMP_NTZ,
    CELL_ID VARCHAR(50),
    RRC_SUCCESS_RATE FLOAT,
    ERAB_SUCCESS_RATE FLOAT,
    DL_THROUGHPUT_MBPS FLOAT,
    UL_THROUGHPUT_MBPS FLOAT,
    PRB_UTILIZATION FLOAT,
    ACTIVE_USERS INTEGER,
    HANDOVER_SUCCESS_RATE FLOAT,
    LATENCY_MS FLOAT
);

-- Core Performance Facts (aggregated)
CREATE TABLE IF NOT EXISTS FACT_CORE_PERFORMANCE (
    TIMESTAMP TIMESTAMP_NTZ,
    ELEMENT_ID VARCHAR(50),
    ATTACH_SUCCESS_RATE FLOAT,
    PDN_CONN_SUCCESS_RATE FLOAT,
    SERVICE_REQUEST_SUCCESS_RATE FLOAT,
    THROUGHPUT_GBPS FLOAT,
    ACTIVE_BEARERS INTEGER,
    LATENCY_MS FLOAT
);

-- =============================================================================
-- SECTION 7: RAN TABLES (4G)
-- =============================================================================
USE SCHEMA RAN_4G;

CREATE TABLE IF NOT EXISTS ENODEB_PERFORMANCE (
    TIMESTAMP TIMESTAMP_NTZ,
    ENODEB_ID VARCHAR(50),
    CELL_ID VARCHAR(50),
    RRC_CONNESTABATT INTEGER,
    RRC_CONNESTABSUCC INTEGER,
    ERAB_ESTABATT INTEGER,
    ERAB_ESTABSUCC INTEGER,
    DL_PRB_USAGE_RATE FLOAT,
    UL_PRB_USAGE_RATE FLOAT,
    AVG_DL_THPT_MBPS FLOAT,
    AVG_UL_THPT_MBPS FLOAT,
    ACTIVE_UE_COUNT INTEGER,
    HO_OUT_ATT INTEGER,
    HO_OUT_SUCC INTEGER
);

-- =============================================================================
-- SECTION 8: RAN TABLES (5G)
-- =============================================================================
USE SCHEMA RAN_5G;

CREATE TABLE IF NOT EXISTS GNODEB_PERFORMANCE (
    TIMESTAMP TIMESTAMP_NTZ,
    GNODEB_ID VARCHAR(50),
    CELL_ID VARCHAR(50),
    RRC_CONNESTABATT INTEGER,
    RRC_CONNESTABSUCC INTEGER,
    PDU_SESSION_ESTAB_ATT INTEGER,
    PDU_SESSION_ESTAB_SUCC INTEGER,
    DL_PRB_USAGE_RATE FLOAT,
    UL_PRB_USAGE_RATE FLOAT,
    AVG_DL_THPT_MBPS FLOAT,
    AVG_UL_THPT_MBPS FLOAT,
    ACTIVE_UE_COUNT INTEGER,
    XNHO_OUT_ATT INTEGER,
    XNHO_OUT_SUCC INTEGER
);

-- =============================================================================
-- SECTION 9: CORE TABLES (4G)
-- =============================================================================
USE SCHEMA CORE_4G;

CREATE TABLE IF NOT EXISTS MME_4G (
    TIMESTAMP TIMESTAMP_NTZ,
    MME_ID VARCHAR(50),
    ATTACH_ATT INTEGER,
    ATTACH_SUCC INTEGER,
    TAU_ATT INTEGER,
    TAU_SUCC INTEGER,
    SERVICE_REQ_ATT INTEGER,
    SERVICE_REQ_SUCC INTEGER,
    PAGING_ATT INTEGER,
    PAGING_SUCC INTEGER
);

CREATE TABLE IF NOT EXISTS SGW_4G (
    TIMESTAMP TIMESTAMP_NTZ,
    SGW_ID VARCHAR(50),
    CREATE_SESSION_ATT INTEGER,
    CREATE_SESSION_SUCC INTEGER,
    MODIFY_BEARER_ATT INTEGER,
    MODIFY_BEARER_SUCC INTEGER,
    THROUGHPUT_GBPS FLOAT,
    ACTIVE_BEARERS INTEGER
);

CREATE TABLE IF NOT EXISTS PGW_4G (
    TIMESTAMP TIMESTAMP_NTZ,
    PGW_ID VARCHAR(50),
    CREATE_SESSION_ATT INTEGER,
    CREATE_SESSION_SUCC INTEGER,
    IP_ALLOC_ATT INTEGER,
    IP_ALLOC_SUCC INTEGER,
    THROUGHPUT_GBPS FLOAT,
    ACTIVE_PDN_CONN INTEGER
);

-- =============================================================================
-- SECTION 10: CORE TABLES (5G)
-- =============================================================================
USE SCHEMA CORE_5G;

CREATE TABLE IF NOT EXISTS AMF_5G (
    TIMESTAMP TIMESTAMP_NTZ,
    AMF_ID VARCHAR(50),
    REGISTRATION_ATT INTEGER,
    REGISTRATION_SUCC INTEGER,
    DEREGISTRATION_ATT INTEGER,
    DEREGISTRATION_SUCC INTEGER,
    SERVICE_REQ_ATT INTEGER,
    SERVICE_REQ_SUCC INTEGER
);

CREATE TABLE IF NOT EXISTS SMF_5G (
    TIMESTAMP TIMESTAMP_NTZ,
    SMF_ID VARCHAR(50),
    PDU_SESSION_ESTAB_ATT INTEGER,
    PDU_SESSION_ESTAB_SUCC INTEGER,
    PDU_SESSION_MOD_ATT INTEGER,
    PDU_SESSION_MOD_SUCC INTEGER,
    ACTIVE_SESSIONS INTEGER
);

CREATE TABLE IF NOT EXISTS UPF_5G (
    TIMESTAMP TIMESTAMP_NTZ,
    UPF_ID VARCHAR(50),
    THROUGHPUT_GBPS FLOAT,
    PACKET_DROP_RATE FLOAT,
    LATENCY_MS FLOAT,
    ACTIVE_SESSIONS INTEGER
);

-- =============================================================================
-- SECTION 11: TRANSPORT TABLES
-- =============================================================================
USE SCHEMA TRANSPORT;

CREATE TABLE IF NOT EXISTS TRANSPORT_DEVICE_PERFORMANCE (
    TIMESTAMP TIMESTAMP_NTZ,
    DEVICE_ID VARCHAR(50),
    DEVICE_TYPE VARCHAR(50),
    LINK_UTILIZATION FLOAT,
    LATENCY_MS FLOAT,
    PACKET_LOSS_RATE FLOAT,
    JITTER_MS FLOAT,
    THROUGHPUT_GBPS FLOAT
);

-- =============================================================================
-- SECTION 12: GRANTS (Optional - adjust for your role structure)
-- =============================================================================
-- Uncomment and modify as needed for your environment

-- GRANT USAGE ON WAREHOUSE NETWORK_OPS_WH TO ROLE <YOUR_ROLE>;
-- GRANT USAGE ON DATABASE NETWORK_OPERATIONS TO ROLE <YOUR_ROLE>;
-- GRANT USAGE ON ALL SCHEMAS IN DATABASE NETWORK_OPERATIONS TO ROLE <YOUR_ROLE>;
-- GRANT SELECT ON ALL TABLES IN DATABASE NETWORK_OPERATIONS TO ROLE <YOUR_ROLE>;

-- =============================================================================
-- SECTION 13: DATA LOADING COMMANDS
-- Run these after uploading CSV files to @STAGING.CSV_DATA
-- =============================================================================

/*
USE WAREHOUSE NETWORK_OPS_BUILD_WH;
USE DATABASE NETWORK_OPERATIONS;

-- Load Dimension Tables
COPY INTO ANALYTICS.DIM_CELL_SITE FROM @STAGING.CSV_DATA/DIM_CELL_SITE.csv FILE_FORMAT = STAGING.CSV_FORMAT;
COPY INTO ANALYTICS.DIM_NETWORK_ELEMENT FROM @STAGING.CSV_DATA/DIM_NETWORK_ELEMENT.csv FILE_FORMAT = STAGING.CSV_FORMAT;

-- Load RAN 4G
COPY INTO RAN_4G.ENODEB_PERFORMANCE FROM @STAGING.CSV_DATA/ENODEB_PERFORMANCE.csv FILE_FORMAT = STAGING.CSV_FORMAT;

-- Load RAN 5G  
COPY INTO RAN_5G.GNODEB_PERFORMANCE FROM @STAGING.CSV_DATA/GNODEB_PERFORMANCE.csv FILE_FORMAT = STAGING.CSV_FORMAT;

-- Load Core 4G
COPY INTO CORE_4G.MME_4G FROM @STAGING.CSV_DATA/MME_4G.csv FILE_FORMAT = STAGING.CSV_FORMAT;
COPY INTO CORE_4G.SGW_4G FROM @STAGING.CSV_DATA/SGW_4G.csv FILE_FORMAT = STAGING.CSV_FORMAT;
COPY INTO CORE_4G.PGW_4G FROM @STAGING.CSV_DATA/PGW_4G.csv FILE_FORMAT = STAGING.CSV_FORMAT;

-- Load Core 5G
COPY INTO CORE_5G.AMF_5G FROM @STAGING.CSV_DATA/AMF_5G.csv FILE_FORMAT = STAGING.CSV_FORMAT;
COPY INTO CORE_5G.SMF_5G FROM @STAGING.CSV_DATA/SMF_5G.csv FILE_FORMAT = STAGING.CSV_FORMAT;
COPY INTO CORE_5G.UPF_5G FROM @STAGING.CSV_DATA/UPF_5G.csv FILE_FORMAT = STAGING.CSV_FORMAT;

-- Load Transport
COPY INTO TRANSPORT.TRANSPORT_DEVICE_PERFORMANCE FROM @STAGING.CSV_DATA/TRANSPORT_DEVICE_PERFORMANCE.csv FILE_FORMAT = STAGING.CSV_FORMAT;

-- Load Aggregated Facts
COPY INTO ANALYTICS.FACT_RAN_PERFORMANCE FROM @STAGING.CSV_DATA/FACT_RAN_PERFORMANCE.csv FILE_FORMAT = STAGING.CSV_FORMAT;
COPY INTO ANALYTICS.FACT_CORE_PERFORMANCE FROM @STAGING.CSV_DATA/FACT_CORE_PERFORMANCE.csv FILE_FORMAT = STAGING.CSV_FORMAT;
*/

-- =============================================================================
-- TEARDOWN SCRIPT (Uncomment to remove all objects)
-- =============================================================================

/*
USE ROLE ACCOUNTADMIN;

-- Drop Agent (if created)
DROP AGENT IF EXISTS SNOWFLAKE_INTELLIGENCE.AGENTS.NETWORK_OPERATIONS_AGENT;

-- Drop Streamlit (if created)
DROP STREAMLIT IF EXISTS NETWORK_OPERATIONS.ANALYTICS.NETWORK_OPS_DASHBOARD;

-- Drop Database (cascades to all schemas, tables, stages)
DROP DATABASE IF EXISTS NETWORK_OPERATIONS;

-- Drop Warehouses
DROP WAREHOUSE IF EXISTS NETWORK_OPS_WH;
DROP WAREHOUSE IF EXISTS NETWORK_OPS_BUILD_WH;
*/
