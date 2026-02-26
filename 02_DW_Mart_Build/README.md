# Data Warehouse & Mart Build: Production ETL Pipeline
## 📋 Overview
An end-to-end data engineering pipeline that transforms raw CSV files from Google Cloud Storage into a normalized star schema data warehouse, then builds analytical data marts with idempotent operations and incremental update patterns.

![Pipeline](../Resources/02_Project2_Data_Pipeline.png)

## Problem & Context
Raw job posting data arrives as flat CSV files in Google Cloud Storage—not structured for analytical queries. <br> Analysts need to answer the following:

1. *Which skills are most in-demand over time?*
2. *What are hiring trends by company and location?*
3. *How do salary patterns vary by role and skill?*
4. *Which priority roles (Data Engineer, Senior Data Engineer) should leadership track?*

**Challenge:** <br> Data teams need a single source of truth system—a data warehouse—to enable consistent, reliable analysis across the organization. Additionally, specialized data marts are required to optimize resources by pre-aggregating data for specific business use cases, reducing query complexity and improving performance.

**Solution:** <br> End-to-end ETL pipeline that extracts CSVs from cloud storage, normalizes them into a star schema warehouse (separating facts from dimensions), and creates specialized data marts optimized for specific use cases—all with idempotent operations ensuring safe re-execution.

## 🧰 Tech Stack
**Database:** DuckDB (file-based OLAP with Google Cloud Storage integration via httpfs)

**Language:** SQL (DDL for schema design, DML for data loading and transformation)

**Data Model:** Star schema with fact tables, dimensions, and bridge tables

**Development:** VS Code + DuckDB CLI

**Orchestration:** Master SQL script for pipeline automation

**Version Control:** Git/GitHub for versioned pipeline scripts

**Storage:** Google Cloud Storage for source CSV files

## 📂 Repository Structure
## WH_Mart_Build

├── 01_create_tables_dw.sql <br> # Star schema DDL

├── 02_load_schema_dw.sql <br> # GCS data extraction & loading

├── 03_create_flat_mart.sql <br> # Denormalized flat mart

├── 04_create_skills_mart.sql <br> # Skills demand mart

├── 05_create_priority_mart.sql <br> # Priority roles mart

├── 06_update_priority_mart.sql <br> # Priority mart incremental update (MERGE)

├── 07_create_company_mart.sql <br> # Company hiring mart (optional)

├── build_dw_marts.sql <br> # Master SQL build script

└── README.md

## Idempotency: A Core Design Principle
All scripts are idempotent—they can be run multiple times with identical results.

## Data Warehouse

![DW](../Resources/03_Data_Warehouse.png)

The data warehouse implements a star schema with company_dim, skills_dim, job_postings_fact, and skills_job_dim tables.

### SQL Files
    01_create_tables_dw.sql: Defines the star schema with 4 core tables

    02_load_schema_dw.sql: Loads data from GCS CSV files into warehouse tables

**Purpose:** Creates a single source of truth for analytical queries using star schema design

*P.S* :  Fact table (job_postings_fact) contains one row per job posting

## 📈 Data Marts
    1. Flat Mart (03_create_flat_mart.sql)
    Purpose: Denormalized table for quick ad-hoc queries

![Flat_Mart](../Resources/04_Flat_Mart.png)

    2. Skills Mart (04_create_skills_mart.sql)
    Purpose: Time-series analysis of skill demand with additive measures

![Skills_Mart](../Resources/05_Skills_Mart.png)

    3. Priority Mart (05-06_priority_mart.sql)
    Purpose: Track priority roles with incremental updates

![Priority_Mart](../Resources/06_Priority_Mart.png)

    4. Company Mart (07_create_company_mart.sql)
    Purpose: Company hiring trends by role, location, and month

![Company_Mart](../Resources/07_Company_Mart.png)

## 💻 Data Engineering Skills Demonstrated
**ETL Pipeline Development**
1. Direct GCS CSV ingestion via `httpfs`
2. Data normalization and type conversion
3. Idempotent table creation
4. `MERGE` operations for incremental updates
5. Master script orchestration

**Dimensional Modeling**
1. Star schema with fact and dimension tables
2. Bridge tables for many-to-many relationships

**SQL Advanced Techniques**
1. DDL: `CREATE TABLE`, `DROP TABLE`, `CREATE SCHEMA`
2. DML: `INSERT INTO` ... `SELECT` with column mapping
3. MERGE: For incremental updates
4. CTEs for complex transformations
5. Date functions for temporal dimensions
6. String functions for data cleaning
7. Boolean logic for flag aggregation

**Data Quality & Production**
1. Idempotent script execution
2. Step-wise data validation
3. Strict type safety
4. Logical schema organization
5. Clear error handling

