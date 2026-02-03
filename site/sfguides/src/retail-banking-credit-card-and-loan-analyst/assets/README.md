# Retail Banking Credit Card and Loan Analyst

## Overview

This guide demonstrates how Snowflake Cortex Agents with Semantic Views enable conversational analytics across auto loans and credit card portfolios for retail banking. You'll build a Consumer Bank Agent that can answer natural language questions spanning two lines of business.

## What You'll Learn

- How to create **Semantic Views** that define business-friendly data models
- How **Cortex Analyst** translates natural language into accurate SQL queries  
- How **Cortex Agents** orchestrate multiple data sources to answer complex questions
- How to use **Snowflake Intelligence** for AI-powered analytics

## What You'll Build

| Component | Description |
|-----------|-------------|
| **Database** | `BANKING_DB` with `AUTO_LOANS` and `CREDIT` schemas |
| **Semantic Views** | Two semantic views for auto loans and credit card data |
| **Cortex Agent** | Multi-LOB agent (`CONSUMER_BANK_AGENT`) for conversational analytics |
| **Sample Data** | Customers, loans, payments, vehicles, credit cards, transactions |

## Deployment

1. **Run Setup Script**: Open `scripts/setup.sql` in a Snowflake SQL Worksheet and execute all statements
2. **Open Snowflake Intelligence**: Navigate to Snowflake Intelligence in Snowsight
3. **Select the Agent**: Choose `Consumer Bank Agent` and start prompting with the example questions below

## Example Questions

**Auto Loans:**
- "Total loans and total principal by month for the last 12 months"
- "Show me customers with late or missed payments"

**Credit Cards:**
- "Active cards, average credit limit, and average APR by product"
- "Show transaction volume by merchant category"

**Cross-Portfolio:**
- "Customers with both an active auto loan and an active credit card"
- "Total exposure per customer (loan principal + card balance)"
