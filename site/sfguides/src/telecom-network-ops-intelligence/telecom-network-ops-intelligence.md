author: Sreedhar Rao, Pedro Jose, Siddharth Pandit, Joviane Bellegarde
id: telecom-network-ops-intelligence
summary: Build an end-to-end telecom network operations solution with 4 persona dashboards, 3D visualization, and Snowflake Intelligence for natural language queries
categories: snowflake-site:taxonomy/solution-center/certification/quickstart, snowflake-site:taxonomy/solution-center/certification/certified-solution, snowflake-site:taxonomy/industry/telecommunications, snowflake-site:taxonomy/product/ai, snowflake-site:taxonomy/snowflake-feature/streamlit-in-snowflake, snowflake-site:taxonomy/snowflake-feature/cortex-ai
environments: web
language: en
status: Published
feedback link: https://github.com/Snowflake-Labs/sfguides/issues
tags: Getting Started, Telecom, Network Operations, Streamlit, Snowflake Intelligence, Cortex, Semantic View, 5G, 4G
fork repo link: https://github.com/Snowflake-Labs/sfguide-telecom-network-ops-intelligence

# End-to-End Telecom Network Operations Reporting and Analytics

## Overview

Telecom network operations teams face the challenge of monitoring thousands of network elements across RAN, Transport, and Core infrastructure while meeting stringent SLA requirements. This guide demonstrates how to build a comprehensive network operations solution using **Snowflake Intelligence** and **Streamlit in Snowflake**.

In this Guide, you will build a complete network operations platform that:
- Monitors 450+ cell sites across 4G and 5G networks
- Provides role-based dashboards for 4 key personas
- Enables natural language queries via Snowflake Intelligence
- Visualizes network topology with 3D mapping

### What You Will Build
- Multi-persona Streamlit dashboard (Network Engineer, Analyst, Manager, Executive)
- Real-time KPI monitoring for RAN, Transport, and Core networks
- 3D network visualization with PyDeck
- Snowflake Intelligence Agent for natural language queries
- Semantic View for structured data access

### What You Will Learn
- How to deploy Streamlit applications in Snowflake
- How to create Semantic Views for natural language queries
- How to configure Snowflake Intelligence Agents
- How to visualize geospatial data with PyDeck
- How to build role-based analytics dashboards

### Prerequisites
- A Snowflake account with ACCOUNTADMIN privileges
- Go to the [Snowflake](https://signup.snowflake.com/?utm_source=snowflake-devrel&utm_medium=developer-guides&utm_cta=developer-guides) sign-up page and register for a free account
- Basic familiarity with SQL and Python

<!-- ------------------------ -->
## Architecture Overview

### Solution Architecture

The Network Operations solution provides end-to-end visibility across telecom infrastructure:

![Architecture Diagram](assets/img/architecture.png)

**Data Layer:**
- **RAN_4G / RAN_5G**: Radio Access Network metrics (eNodeB, gNodeB)
- **CORE_4G / CORE_5G**: Core network elements (MME, SGW, PGW, AMF, SMF, UPF)
- **TRANSPORT**: Backhaul and fronthaul device performance
- **ANALYTICS**: Aggregated facts and dimension tables

**Application Layer:**
- **Streamlit Dashboard**: 4 persona-specific views
- **Snowflake Intelligence Agent**: Natural language interface
- **Semantic View**: Structured query definitions

### Key Personas

| Persona | Focus Area | Key Metrics |
|---------|------------|-------------|
| **Network Engineer** | Real-time troubleshooting | MTTD, MTTR, Alarms |
| **Performance Analyst** | Capacity planning | PRB Utilization, Throughput |
| **Network Manager** | SLA management | Success Rates, Coverage |
| **Executive** | Business impact | Revenue at Risk, Churn |

### Data Model

The solution includes approximately 600,000 performance records across:
- 450 cell sites in Portugal (Lisboa, Porto, Braga, Coimbra, Faro)
- September 2025 time period
- 15-minute measurement intervals

<!-- ------------------------ -->
## Setup Snowflake Environment

In this step, you'll create all the Snowflake objects needed for the Network Operations solution.

### Step 1: Create Database Objects

1. In Snowsight, click `Projects`, then `Workspaces` in the left navigation, or [click here](https://app.snowflake.com/_deeplink/#/workspaces?utm_source=quickstart&utm_medium=quickstart&utm_campaign=-us-en-all&utm_content=app-network-operations-reporting-analytics-snowflake-intelligence) to go there directly
2. Click `+ Add new` to create a new Workspace
3. Click `SQL File` to create a new SQL file
4. Copy the setup script from [setup.sql](https://github.com/Snowflake-Labs/sfguide-telecom-network-ops-intelligence/blob/main/assets/scripts/setup.sql) and paste it into your SQL file

### Step 2: Run Infrastructure Setup

Run the setup script to create:
- **Database**: `NETWORK_OPERATIONS` with 7 schemas
- **Warehouses**: `NETWORK_OPS_WH` for queries, `NETWORK_OPS_BUILD_WH` for data loading
- **Stages**: `CSV_DATA` for data files, `STREAMLIT_STAGE` for app deployment
- **Tables**: Dimension and fact tables for network data

```sql
-- Example: Creating the database structure
CREATE DATABASE IF NOT EXISTS NETWORK_OPERATIONS;

CREATE SCHEMA IF NOT EXISTS NETWORK_OPERATIONS.RAN_4G;
CREATE SCHEMA IF NOT EXISTS NETWORK_OPERATIONS.RAN_5G;
CREATE SCHEMA IF NOT EXISTS NETWORK_OPERATIONS.CORE_4G;
CREATE SCHEMA IF NOT EXISTS NETWORK_OPERATIONS.CORE_5G;
CREATE SCHEMA IF NOT EXISTS NETWORK_OPERATIONS.TRANSPORT;
CREATE SCHEMA IF NOT EXISTS NETWORK_OPERATIONS.ANALYTICS;
CREATE SCHEMA IF NOT EXISTS NETWORK_OPERATIONS.STAGING;
```

### Step 3: Download Data Files

Download the CSV data files from the GitHub repository:

- [DIM_CELL_SITE.csv](https://github.com/Snowflake-Labs/sfguide-telecom-network-ops-intelligence/blob/main/assets/scripts/DIM_CELL_SITE.csv) (450 sites)
- [DIM_NETWORK_ELEMENT.csv](https://github.com/Snowflake-Labs/sfguide-telecom-network-ops-intelligence/blob/main/assets/scripts/DIM_NETWORK_ELEMENT.csv) (480 elements)
- [ENODEB_PERFORMANCE.csv](https://github.com/Snowflake-Labs/sfguide-telecom-network-ops-intelligence/blob/main/assets/scripts/ENODEB_PERFORMANCE.csv) (426K records)
- [GNODEB_PERFORMANCE.csv](https://github.com/Snowflake-Labs/sfguide-telecom-network-ops-intelligence/blob/main/assets/scripts/GNODEB_PERFORMANCE.csv) (178K records)
- [FACT_RAN_PERFORMANCE.csv](https://github.com/Snowflake-Labs/sfguide-telecom-network-ops-intelligence/blob/main/assets/scripts/FACT_RAN_PERFORMANCE.csv) (604K records)
- [FACT_CORE_PERFORMANCE.csv](https://github.com/Snowflake-Labs/sfguide-telecom-network-ops-intelligence/blob/main/assets/scripts/FACT_CORE_PERFORMANCE.csv) (13K records)
- [TRANSPORT_DEVICE_PERFORMANCE.csv](https://github.com/Snowflake-Labs/sfguide-telecom-network-ops-intelligence/blob/main/assets/scripts/TRANSPORT_DEVICE_PERFORMANCE.csv) (604K records)
- Core element files: [MME_4G.csv](https://github.com/Snowflake-Labs/sfguide-telecom-network-ops-intelligence/blob/main/assets/scripts/MME_4G.csv), [SGW_4G.csv](https://github.com/Snowflake-Labs/sfguide-telecom-network-ops-intelligence/blob/main/assets/scripts/SGW_4G.csv), [PGW_4G.csv](https://github.com/Snowflake-Labs/sfguide-telecom-network-ops-intelligence/blob/main/assets/scripts/PGW_4G.csv), [AMF_5G.csv](https://github.com/Snowflake-Labs/sfguide-telecom-network-ops-intelligence/blob/main/assets/scripts/AMF_5G.csv), [SMF_5G.csv](https://github.com/Snowflake-Labs/sfguide-telecom-network-ops-intelligence/blob/main/assets/scripts/SMF_5G.csv), [UPF_5G.csv](https://github.com/Snowflake-Labs/sfguide-telecom-network-ops-intelligence/blob/main/assets/scripts/UPF_5G.csv)

### Step 4: Upload Data to Stage

1. In Snowsight, navigate to `Data` → `Databases` → `NETWORK_OPERATIONS` → `STAGING`
2. Click on the `CSV_DATA` stage
3. Click `+ Files` and upload all downloaded CSV files

![Upload Data Files](assets/upload_data.png)

<!-- ------------------------ -->
## Load Data

### Step 1: Load Dimension Tables

Run the data loading commands from the setup script:

```sql
USE DATABASE NETWORK_OPERATIONS;
USE SCHEMA STAGING;

-- Load Cell Site Dimension
COPY INTO ANALYTICS.DIM_CELL_SITE
FROM @CSV_DATA/DIM_CELL_SITE.csv
FILE_FORMAT = (TYPE = 'CSV' SKIP_HEADER = 1 FIELD_OPTIONALLY_ENCLOSED_BY = '"');

-- Load Network Element Dimension
COPY INTO ANALYTICS.DIM_NETWORK_ELEMENT
FROM @CSV_DATA/DIM_NETWORK_ELEMENT.csv
FILE_FORMAT = (TYPE = 'CSV' SKIP_HEADER = 1 FIELD_OPTIONALLY_ENCLOSED_BY = '"');
```

### Step 2: Load Fact Tables

```sql
-- Load RAN Performance Facts
COPY INTO ANALYTICS.FACT_RAN_PERFORMANCE
FROM @CSV_DATA/FACT_RAN_PERFORMANCE.csv
FILE_FORMAT = (TYPE = 'CSV' SKIP_HEADER = 1 FIELD_OPTIONALLY_ENCLOSED_BY = '"');

-- Load Core Performance Facts
COPY INTO ANALYTICS.FACT_CORE_PERFORMANCE
FROM @CSV_DATA/FACT_CORE_PERFORMANCE.csv
FILE_FORMAT = (TYPE = 'CSV' SKIP_HEADER = 1 FIELD_OPTIONALLY_ENCLOSED_BY = '"');

-- Load Transport Performance
COPY INTO TRANSPORT.TRANSPORT_DEVICE_PERFORMANCE
FROM @CSV_DATA/TRANSPORT_DEVICE_PERFORMANCE.csv
FILE_FORMAT = (TYPE = 'CSV' SKIP_HEADER = 1 FIELD_OPTIONALLY_ENCLOSED_BY = '"');
```

### Step 3: Verify Data Load

```sql
-- Check record counts
SELECT 'DIM_CELL_SITE' AS TABLE_NAME, COUNT(*) AS RECORD_COUNT FROM ANALYTICS.DIM_CELL_SITE
UNION ALL
SELECT 'DIM_NETWORK_ELEMENT', COUNT(*) FROM ANALYTICS.DIM_NETWORK_ELEMENT
UNION ALL
SELECT 'FACT_RAN_PERFORMANCE', COUNT(*) FROM ANALYTICS.FACT_RAN_PERFORMANCE
UNION ALL
SELECT 'FACT_CORE_PERFORMANCE', COUNT(*) FROM ANALYTICS.FACT_CORE_PERFORMANCE;
```

Expected output:
| TABLE_NAME | RECORD_COUNT |
|------------|--------------|
| DIM_CELL_SITE | 450 |
| DIM_NETWORK_ELEMENT | 480 |
| FACT_RAN_PERFORMANCE | 604,800 |
| FACT_CORE_PERFORMANCE | 13,440 |

<!-- ------------------------ -->
## Deploy Streamlit Application

### Step 1: Download Streamlit Files

Download the Streamlit application files from GitHub:
- [streamlit_app.py](https://github.com/Snowflake-Labs/sfguide-telecom-network-ops-intelligence/blob/main/assets/scripts/streamlit_app.py)
- [environment.yml](https://github.com/Snowflake-Labs/sfguide-telecom-network-ops-intelligence/blob/main/assets/scripts/environment.yml)

### Step 2: Upload to Stage

1. In Snowsight, navigate to `Data` → `Databases` → `NETWORK_OPERATIONS` → `STAGING`
2. Click on the `STREAMLIT_STAGE` stage
3. Upload both `streamlit_app.py` and `environment.yml`

### Step 3: Create Streamlit App

Run the following SQL to create the Streamlit application:

```sql
CREATE OR REPLACE STREAMLIT NETWORK_OPERATIONS.ANALYTICS.NETWORK_OPS_DASHBOARD
  ROOT_LOCATION = '@NETWORK_OPERATIONS.STAGING.STREAMLIT_STAGE'
  MAIN_FILE = 'streamlit_app.py'
  QUERY_WAREHOUSE = 'NETWORK_OPS_WH'
  COMMENT = '{"origin":"sf_sit-is", "name":"network_operations", "version":{"major":1, "minor":0}}';
```

### Step 4: Launch the Dashboard

1. In Snowsight, navigate to `Projects` → `Streamlit`
2. Find `NETWORK_OPS_DASHBOARD` in the list
3. Click to open the application

![Streamlit Dashboard](assets/streamlit_dashboard.png)

<!-- ------------------------ -->
## Explore the Dashboards

### Network Engineer View

The Network Engineer dashboard focuses on real-time troubleshooting:

![Network Engineer Dashboard](assets/dashboard_network_engineer.png)

**Key Features:**
- **Active Alarms**: Real-time alarm monitoring with severity levels
- **MTTD/MTTR Metrics**: Mean Time to Detect and Mean Time to Resolve
- **Cell Site Map**: 3D visualization of network topology
- **Drill-down Analysis**: Click any site for detailed metrics

### Performance Analyst View

The Performance Analyst dashboard focuses on capacity planning:

![Performance Analyst Dashboard](assets/dashboard_analyst.png)

**Key Features:**
- **PRB Utilization Trends**: Physical Resource Block usage over time
- **Throughput Analysis**: Uplink/Downlink performance
- **Capacity Forecasting**: Predictive capacity trends
- **Comparative Analysis**: Site-to-site performance comparison

### Network Manager View

The Network Manager dashboard focuses on SLA management:

**Key Features:**
- **SLA Compliance**: Real-time SLA tracking
- **Team Performance**: Issue resolution metrics
- **Coverage Analysis**: Network coverage gaps
- **Executive Summary**: High-level operational status

### Executive View

The Executive dashboard focuses on business impact:

**Key Features:**
- **Revenue at Risk**: Financial impact of network issues
- **Churn Indicators**: Customer experience metrics
- **Strategic KPIs**: High-level performance indicators
- **Trend Analysis**: Month-over-month comparisons

<!-- ------------------------ -->
## Create Semantic View

A Semantic View enables natural language queries against your network data.

### Step 1: Create the Semantic View

Run the semantic view creation script:

```sql
CREATE OR REPLACE SEMANTIC VIEW NETWORK_OPERATIONS.ANALYTICS.NETWORK_SEMANTIC_VIEW
  COMMENT = 'Semantic view for telecom network operations analytics'
  AS $$
schema:
  tables:
    - name: DIM_CELL_SITE
      base_table:
        database: NETWORK_OPERATIONS
        schema: ANALYTICS
        table: DIM_CELL_SITE
      description: Cell site dimension with location and configuration data
      columns:
        - name: CELL_ID
          description: Unique identifier for the cell site
          data_type: VARCHAR
        - name: SITE_NAME
          description: Human-readable name of the cell site
          data_type: VARCHAR
        - name: REGION
          description: Geographic region (Lisboa, Porto, Braga, Coimbra, Faro)
          data_type: VARCHAR
        - name: NETWORK_TYPE
          description: Network technology (4G LTE or 5G NR)
          data_type: VARCHAR
        - name: LOCATION_LAT
          description: Latitude coordinate
          data_type: FLOAT
        - name: LOCATION_LON
          description: Longitude coordinate
          data_type: FLOAT
          
    - name: FACT_RAN_PERFORMANCE
      base_table:
        database: NETWORK_OPERATIONS
        schema: ANALYTICS
        table: FACT_RAN_PERFORMANCE
      description: RAN performance metrics including success rates and throughput
      columns:
        - name: TIMESTAMP
          description: Measurement timestamp
          data_type: TIMESTAMP_NTZ
        - name: CELL_ID
          description: Cell site identifier (foreign key to DIM_CELL_SITE)
          data_type: VARCHAR
        - name: RRC_SUCCESS_RATE
          description: RRC Connection Success Rate percentage
          data_type: FLOAT
        - name: ERAB_SUCCESS_RATE
          description: E-RAB Setup Success Rate percentage
          data_type: FLOAT
        - name: DL_THROUGHPUT_MBPS
          description: Downlink throughput in Mbps
          data_type: FLOAT
        - name: UL_THROUGHPUT_MBPS
          description: Uplink throughput in Mbps
          data_type: FLOAT
        - name: PRB_UTILIZATION
          description: Physical Resource Block utilization percentage
          data_type: FLOAT

  relationships:
    - name: cell_performance
      left_table: FACT_RAN_PERFORMANCE
      right_table: DIM_CELL_SITE
      join_type: left
      relationship_columns:
        - left_column: CELL_ID
          right_column: CELL_ID

  verified_queries:
    - name: Top 10 Cells by Throughput
      question: What are the top 10 cell sites by average downlink throughput?
      sql: |
        SELECT d.SITE_NAME, d.REGION, AVG(f.DL_THROUGHPUT_MBPS) as AVG_THROUGHPUT
        FROM NETWORK_OPERATIONS.ANALYTICS.FACT_RAN_PERFORMANCE f
        JOIN NETWORK_OPERATIONS.ANALYTICS.DIM_CELL_SITE d ON f.CELL_ID = d.CELL_ID
        GROUP BY d.SITE_NAME, d.REGION
        ORDER BY AVG_THROUGHPUT DESC
        LIMIT 10
        
    - name: Regional Performance Summary
      question: Show me the average RRC success rate by region
      sql: |
        SELECT d.REGION, AVG(f.RRC_SUCCESS_RATE) as AVG_SUCCESS_RATE
        FROM NETWORK_OPERATIONS.ANALYTICS.FACT_RAN_PERFORMANCE f
        JOIN NETWORK_OPERATIONS.ANALYTICS.DIM_CELL_SITE d ON f.CELL_ID = d.CELL_ID
        GROUP BY d.REGION
        ORDER BY AVG_SUCCESS_RATE DESC
$$;
```

### Step 2: Verify the Semantic View

```sql
-- Test the semantic view
DESCRIBE SEMANTIC VIEW NETWORK_OPERATIONS.ANALYTICS.NETWORK_SEMANTIC_VIEW;
```

<!-- ------------------------ -->
## Configure Snowflake Intelligence Agent

### Step 1: Create the Agent

Run the agent creation script:

```sql
CREATE OR REPLACE AGENT SNOWFLAKE_INTELLIGENCE.AGENTS.NETWORK_OPERATIONS_AGENT
  COMMENT = 'Network Operations Intelligence Agent for natural language queries'
  MODEL = 'claude-3-5-sonnet'
  SYSTEM_PROMPT = 'You are a telecom network operations expert assistant. Help users analyze network performance data, identify issues, and provide recommendations. Always provide context about the metrics and their business impact.'
  TOOLS = (
    SEMANTIC_VIEW_TOOL(
      SEMANTIC_VIEW => 'NETWORK_OPERATIONS.ANALYTICS.NETWORK_SEMANTIC_VIEW'
    )
  );
```

### Step 2: Test the Agent

Navigate to Snowflake Intelligence in Snowsight and try these queries:

**Example Queries:**
- "What are the top 5 worst performing cell sites today?"
- "Show me the average throughput by region"
- "Which sites have RRC success rate below 95%?"
- "Compare 4G vs 5G network performance"

![Snowflake Intelligence](assets/snowflake_intelligence.png)

<!-- ------------------------ -->
## Cleanup

To remove all resources created by this guide:

### Step 1: Drop the Agent

```sql
DROP AGENT IF EXISTS SNOWFLAKE_INTELLIGENCE.AGENTS.NETWORK_OPERATIONS_AGENT;
```

### Step 2: Drop the Streamlit App

```sql
DROP STREAMLIT IF EXISTS NETWORK_OPERATIONS.ANALYTICS.NETWORK_OPS_DASHBOARD;
```

### Step 3: Drop Database and Warehouses

```sql
DROP DATABASE IF EXISTS NETWORK_OPERATIONS;
DROP WAREHOUSE IF EXISTS NETWORK_OPS_WH;
DROP WAREHOUSE IF EXISTS NETWORK_OPS_BUILD_WH;
```

<!-- ------------------------ -->
## Conclusion and Resources

Congratulations! You have successfully built a comprehensive telecom network operations solution with Snowflake Intelligence.

### What You Learned
- How to structure telecom network data in Snowflake
- How to deploy multi-persona Streamlit dashboards
- How to create Semantic Views for natural language access
- How to configure Snowflake Intelligence Agents
- How to visualize geospatial network data

### Business Value

| Persona | Key Benefit | Estimated Value |
|---------|-------------|-----------------|
| Network Engineer | 40% faster issue detection | €230K-275K/year |
| Performance Analyst | Proactive capacity planning | €1.2M/year |
| Network Manager | SLA protection | €870K/year |
| Executive | Reduced churn | €9.9M/year |

### Related Resources

**Snowflake Documentation:**
- [Streamlit in Snowflake](https://docs.snowflake.com/en/developer-guide/streamlit/about-streamlit)
- [Semantic Views](https://docs.snowflake.com/en/user-guide/views-semantic)
- [Snowflake Intelligence](https://docs.snowflake.com/en/user-guide/snowflake-intelligence/overview)

**Industry Resources:**
- [3GPP Network Standards](https://www.3gpp.org/)
- [TM Forum Operations Frameworks](https://www.tmforum.org/)
