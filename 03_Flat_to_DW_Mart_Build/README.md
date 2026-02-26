# 🏗️ Flat to Data Warehouse Mart Build

An end-to-end data engineering pipeline that transforms flat CSV data into a normalized star schema warehouse with dimension, fact, and bridge tables.

![Data_Warehouse](../Resources/03_Data_Warehouse.png)

## 🧩 Problem & Context
Raw job posting data arrives as flat CSV files in Google Cloud Storage—not structured for analytical queries.

Analysts need to answer the following:

*Which skills are most in-demand over time?*

*What are hiring trends by company and location?* 

*How do salary patterns vary by role and skill?* 

*Which priority roles (Data Engineer, Senior Data Engineer) should leadership track?*

**Challenge:** <br>
Data teams need a single source of truth system—a data warehouse—to enable consistent, reliable analysis across the organization. Additionally, specialized data marts are required to optimize resources by pre-aggregating data for specific business use cases, reducing query complexity and improving performance.

**Solution:** <br>
End-to-end ETL pipeline that extracts CSVs from cloud storage, normalizes them into a star schema warehouse (separating facts from dimensions), and creates specialized data marts optimized for specific use cases—all with idempotent operations ensuring safe re-execution.

## 🧰 Tech Stack
**Database**:🐤 DuckDB (file-based OLAP with GCS integration via httpfs) <br>
**Language**: 🧮 SQL (DDL for schema design, DML for data loading and transformation) <br>
**Data Model**:	📊 Star schema with fact tables, dimensions, and bridge tables <br>
**Development**:	🛠️ VS Code + DuckDB CLI <br>
**Orchestration**:	🔧 Master SQL script for pipeline automation <br>
**Version Control**: 📦 Git/GitHub for versioned pipeline scripts <br>
**Storage**: ☁️ Google Cloud Storage for source CSV files

## 📂 Repository Structure
## Flat_to_DW_Mart_Build
    ├── Data Loading
    └── 00_load_data.sql              
        # Loads raw flat CSV data
    
    ├── Table Creation
    └── 01_create_tables.sql           
        # Creates all warehouse tables (dimensions, fact, bridge)
    
    ├── Dimension Population
    ├── 02_populate_company_dim.sql    
        # Populates company dimension table
    └── 03_populate_skills_dim.sql     
        # Populates skills dimension table
    
    ├── Fact Population
    └── 04_populate_fact_table.sql     
        # Populates main fact table
    
    ├── Bridge Population
    └── 05_populate_bridge_table.sql   
        # Populates skills_job_dim bridge table (many-to-many)
    
    ├── Verification
    └── 06_verify_schema.sql           
        # Validates data integrity and row counts
    
    ├── build_warehouse.sql                  
        # Master build script (runs all steps sequentially)

    └── README.md

## 🔄 Idempotency: Core Design Principle
All scripts are idempotent—they can be run multiple times with identical results.

## 💻 Data Engineering Skills Demonstrated
## ETL Pipeline Development
1. **Sequential Processing:** Step-by-step ETL with clear dependencies

2. **Data Extraction:** Loading from flat CSV files

3. **Data Transformation:** Parsing, cleaning, and normalizing

4. **Data Loading:** Idempotent table population

5. **Orchestration:** Master script for pipeline automation

## Dimensional Modeling
1. **Star Schema Design:** Fact + dimension tables

2. **Bridge Tables:** Many-to-many relationship handling

3. **Surrogate Keys:** Sequential ID generation with ROW_NUMBER()

4. **Grain Definition:** Proper granularity at each level

5. **Foreign Key Constraints:** Referential integrity

## SQL Techniques
1. **DDL Operations:** CREATE TABLE, DROP TABLE, CREATE OR REPLACE

2. **DML Operations:** INSERT INTO ... SELECT with transformations

3. **CTEs:** Common Table Expressions for complex parsing

4. **String Functions:** STRING_SPLIT, REPLACE for skill parsing

5. **Window Functions:** ROW_NUMBER() for surrogate keys

6. **UNNEST:** Exploding arrays into rows

## Data Quality & Production Practices
1. **Idempotency:** All scripts safely rerunnable

2. **Data Validation:** Verification queries at each step

3. **Type Safety:** Proper data type definitions

4. **Sequential Dependencies:** Clear step ordering

5. **Error Prevention:** Foreign key constraints

