author: Sreedhar Rao, Pedro Jose, Siddharth Pandit, Joviane Bellegarde
id: telecom-network-ops-intelligence
summary: Build an end-to-end telecom network operations solution with 4 persona dashboards, 3D visualization, and Snowflake Intelligence for natural language queries
categories: snowflake-site:taxonomy/solution-center/certification/quickstart, snowflake-site:taxonomy/solution-center/certification/certified-solution, snowflake-site:taxonomy/industry/telecommunications, snowflake-site:taxonomy/product/ai, snowflake-site:taxonomy/snowflake-feature/streamlit-in-snowflake, snowflake-site:taxonomy/snowflake-feature/cortex-ai
environments: web
language: en
status: Published
feedback link: https://github.com/Snowflake-Labs/sfguides/issues
tags: Getting Started, Telecom, Network Operations, Streamlit, Snowflake Intelligence, Cortex, Semantic View, 5G, 4G
fork repo link: https://github.com/Snowflake-Labs/sfguide-telecom-network-operations-analytics

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
- Go to the <a href="https://signup.snowflake.com/?utm_source=snowflake-devrel&utm_medium=developer-guides&utm_cta=developer-guides" target="_blank">Snowflake</a> sign-up page and register for a free account
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
| **Network Performance** | Capacity planning | PRB Utilization, Throughput |
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

1. In Snowsight, click `Projects`, then `Workspaces` in the left navigation, or <a href="https://app.snowflake.com/_deeplink/#/workspaces?utm_source=quickstart&utm_medium=quickstart&utm_campaign=-us-en-all&utm_content=app-network-operations-reporting-analytics-snowflake-intelligence" target="_blank">click here</a> to go there directly
2. Click `+ Add new` to create a new Workspace
3. Click `SQL File` to create a new SQL file
4. Copy the setup script from <a href="https://github.com/Snowflake-Labs/sfguide-telecom-network-operations-analytics/blob/main/scripts/setup.sql" target="_blank">setup.sql</a> and paste it into your SQL file

### Step 2: Run Infrastructure Setup

Run the setup script to create:
- **Database**: `NETWORK_OPERATIONS` with 7 schemas (RAN_4G, RAN_5G, CORE_4G, CORE_5G, TRANSPORT, ANALYTICS, STAGING)
- **Warehouses**: `NETWORK_OPS_WH` for queries, `NETWORK_OPS_BUILD_WH` for data loading
- **GitHub External Access Integration**: For automatic data loading from GitHub
- **Stages**: `CSV_DATA` for data files, `STREAMLIT_STAGE` for app deployment
- **Tables**: Dimension and fact tables for network data

<!-- ------------------------ -->
## Load Data

The setup script automatically loads all data from GitHub using an External Access Integration. No manual file downloads required!

### Step 1: Data Loading

The script creates a `LOAD_DATA_FROM_GITHUB()` procedure that:
1. Connects to GitHub using the External Access Integration
2. Downloads all 13 CSV files directly from the repository
3. Loads data into the appropriate tables

### Step 2: Verify Data Load

After running the setup script, verify the record counts:

| TABLE_NAME | RECORD_COUNT |
|------------|--------------|
| DIM_CELL_SITE | 450 |
| DIM_NETWORK_ELEMENT | 480 |
| FACT_RAN_PERFORMANCE | 604,800 |
| FACT_CORE_PERFORMANCE | 13,440 |

<!-- ------------------------ -->
## Deploy Streamlit Application

The setup script also automatically downloads and deploys the Streamlit application from GitHub!

### Step 1: Streamlit Deployment

The script creates a `LOAD_STREAMLIT_FROM_GITHUB()` procedure that:
1. Downloads `streamlit_app.py` and `environment.yml` from GitHub
2. Uploads them to the `STREAMLIT_STAGE`
3. Creates the `NETWORK_OPS_DASHBOARD` Streamlit application

### Step 2: Launch the Dashboard

1. In Snowsight, navigate to `Projects` → `Streamlit`
2. Find `NETWORK_OPS_DASHBOARD` in the list
3. Click to open the application

<a href="https://app.snowflake.com/_deeplink/#/streamlit-apps/NETWORK_OPERATIONS.ANALYTICS.NETWORK_OPS_DASHBOARD" target="_blank">Launch Streamlit Dashboard</a>

![Streamlit Dashboard](assets/img/streamlit_dashboard.png)

<!-- ------------------------ -->
## Explore the Dashboards

<details>
<summary><strong>Network Engineer View</strong></summary>

The Network Engineer dashboard focuses on real-time troubleshooting:

![Network Engineer Dashboard](assets/img/dashboard_network_engineer.png)

**Key Features:**
- **Active Alarms**: Real-time alarm monitoring with severity levels
- **MTTD/MTTR Metrics**: Mean Time to Detect and Mean Time to Resolve
- **Cell Site Map**: 3D visualization of network topology
- **Drill-down Analysis**: Click any site for detailed metrics

</details>

<details>
<summary><strong>Network Performance View</strong></summary>

The Network Performance dashboard focuses on capacity planning:

![Network Performance Dashboard](assets/img/dashboard_analyst.png)

**Key Features:**
- **PRB Utilization Trends**: Physical Resource Block usage over time
- **Throughput Analysis**: Uplink/Downlink performance
- **Capacity Forecasting**: Predictive capacity trends
- **Comparative Analysis**: Site-to-site performance comparison

</details>

<details>
<summary><strong>Network Manager View</strong></summary>

The Network Manager dashboard focuses on SLA management:

![Network Manager Dashboard](assets/img/dashboard_manager.png)

**Key Features:**
- **SLA Compliance**: Real-time SLA tracking
- **Team Performance**: Issue resolution metrics
- **Coverage Analysis**: Network coverage gaps
- **Executive Summary**: High-level operational status

</details>

<details>
<summary><strong>Executive View</strong></summary>

The Executive dashboard focuses on business impact:

![Executive Dashboard](assets/img/dashboard_executive.png)

**Key Features:**
- **Revenue at Risk**: Financial impact of network issues
- **Churn Indicators**: Customer experience metrics
- **Strategic KPIs**: High-level performance indicators
- **Trend Analysis**: Month-over-month comparisons

</details>

<!-- ------------------------ -->
## Create Semantic View

A Semantic View enables natural language queries against your network data.

### Step 1: Create the Semantic View

Run the semantic view creation section from the setup script. This creates `NETWORK_SEMANTIC_VIEW` with:
- Table definitions for DIM_CELL_SITE and FACT_RAN_PERFORMANCE
- Column descriptions for natural language understanding
- Relationships between dimension and fact tables
- Verified queries for common analysis patterns

### Step 2: Verify the Semantic View

The setup script includes a DESCRIBE command to verify the semantic view was created successfully.

<!-- ------------------------ -->
## Configure Snowflake Intelligence Agent

### Step 1: Create the Agent

Run the agent creation section from the setup script. This creates the `NETWORK_OPERATIONS_AGENT` with:
- Claude 3.5 Sonnet model for natural language understanding
- System prompt configured for telecom domain expertise
- Semantic View tool for data access

### Step 2: Test the Agent

Navigate to Snowflake Intelligence in Snowsight and try these persona-specific queries:

<details>
<summary><strong>Network Engineer (NOC/Field)</strong></summary>

**1. RRC Success Rate Troubleshooting**

Identify cells falling below the 95% RRC success rate target. This is the first indicator of connection issues that affect subscriber experience and requires immediate attention from field teams.

> Which cells have RRC success below 95% right now?

**What It Shows:** Real-time fault detection for proactive troubleshooting before customer complaints

---

**2. Critical Capacity Alerts**

Find sites with PRB utilization above 85% (critical threshold). These sites are at risk of congestion and degraded service quality during peak hours.

> Show me the top 10 sites with critical PRB utilization above 85%

**What It Shows:** Capacity hotspots requiring immediate attention or traffic offloading

---

**3. 5G Session Issues**

Identify 5G cells with PDU session establishment problems. Low PDU success rates indicate issues with 5G core connectivity affecting new-generation services.

> Which 5G cells in Lisboa have PDU session issues?

**What It Shows:** 5G-specific troubleshooting for next-gen network quality

---

**4. Handover Failures**

Track cells with handover failures impacting mobile subscribers. Poor handover success causes dropped calls and interrupted data sessions during movement.

> List cells with handover failures in the last 24 hours

**What It Shows:** Mobility performance analysis for seamless subscriber experience

</details>

<details>
<summary><strong>Network Performance</strong></summary>

**1. Technology Comparison**

Compare average throughput between 4G and 5G across regions. This analysis supports technology migration planning and validates 5G investment ROI.

> Compare average throughput between 4G and 5G by region

**What It Shows:** Technology benchmarking for strategic planning and 5G business case validation

---

**2. Regional Trend Analysis**

Analyze PRB utilization trends to predict capacity needs. Understanding patterns helps optimize network resources before congestion occurs.

> What is the PRB utilization trend for Porto this week?

**What It Shows:** Trend analysis for proactive capacity planning

---

**3. Uplink vs Downlink Performance**

Compare upload and download performance by technology. Balanced performance is critical for video conferencing and cloud applications.

> Show uplink vs downlink performance by technology

**What It Shows:** Bidirectional performance analysis for QoE optimization

---

**4. Congestion Risk Assessment**

Identify regions with the highest congestion risk based on utilization patterns. Early warning enables preventive capacity expansion.

> Which regions have the highest congestion risk?

**What It Shows:** Risk-based prioritization for network investment decisions

</details>

<details>
<summary><strong>Network Manager (Operations)</strong></summary>

**1. SLA Compliance Overview**

Monitor how many sites are currently below SLA targets. This executive metric drives operational focus and resource allocation decisions.

> How many sites are currently below SLA targets?

**What It Shows:** Operational health scorecard for management reporting

---

**2. Capacity Planning Data**

Review availability metrics by city to inform capacity planning. Geographic insights support data-driven infrastructure investment.

> Show availability metrics by city for capacity planning

**What It Shows:** Regional performance data for CAPEX planning and budget allocation

---

**3. Regional Priority Assessment**

Determine which region has the most sites needing attention. This helps prioritize field team deployment and maintenance scheduling.

> Which region has the most sites needing attention?

**What It Shows:** Resource allocation intelligence for operational efficiency

---

**4. Regional Performance Comparison**

Compare Norte vs Sul performance for resource allocation decisions. Regional benchmarking supports fair and effective team distribution.

> Compare Norte vs Sul performance for resource allocation

**What It Shows:** Cross-regional analysis for balanced operational coverage

</details>

<details>
<summary><strong>Executive (C-Level)</strong></summary>

**1. Network Health Overview**

Get a high-level view of overall network health across Portugal. This board-ready metric summarizes infrastructure performance in business terms.

> What is our overall network health across Portugal?

**What It Shows:** Executive dashboard summary for board reporting and investor communications

---

**2. 5G Investment ROI**

Compare 5G vs 4G performance to validate technology investment. Demonstrates return on 5G CAPEX through measurable performance improvements.

> Show 5G vs 4G performance summary for board reporting

**What It Shows:** Technology ROI validation for strategic investment justification

---

**3. Investment Prioritization**

Identify which regions should be prioritized for network investment. Data-driven recommendations support CAPEX allocation decisions.

> Which regions should be prioritized for investment?

**What It Shows:** Strategic investment guidance based on performance gaps and growth potential

---

**4. SLA Compliance Summary**

Understand what percentage of the network meets SLA targets. This key metric indicates overall service quality and contractual compliance.

> What percentage of our network meets SLA targets?

**What It Shows:** Compliance scorecard for customer commitments and regulatory reporting

</details>

<a href="https://app.snowflake.com/_deeplink/#/agents/database/NETWORK_OPERATIONS/schema/ANALYTICS/agent/NETWORK_OPERATIONS_AGENT/details" target="_blank">Launch Network Operations Agent</a>



<!-- ------------------------ -->
## Cleanup

To remove all resources created by this guide:

1. Open your **setup.sql** Workspace (the same one you used during setup)
2. Scroll to the **TEARDOWN SCRIPT** section at the bottom
3. **Uncomment** the DROP statements
4. **Run** the teardown commands

The teardown script will remove the agent, Streamlit app, database, warehouses, and all other objects created by this guide.

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
| Network Performance | Proactive capacity planning | €1.2M/year |
| Network Manager | SLA protection | €870K/year |
| Executive | Reduced churn | €9.9M/year |

### Related Resources

**Snowflake Documentation:**
- <a href="https://docs.snowflake.com/en/developer-guide/streamlit/about-streamlit" target="_blank">Streamlit in Snowflake</a>
- <a href="https://docs.snowflake.com/en/user-guide/views-semantic" target="_blank">Semantic Views</a>
- <a href="https://docs.snowflake.com/en/user-guide/snowflake-intelligence/overview" target="_blank">Snowflake Intelligence</a>

**Industry Resources:**
- <a href="https://www.3gpp.org/" target="_blank">3GPP Network Standards</a>
- <a href="https://www.tmforum.org/" target="_blank">TM Forum Operations Frameworks</a>
