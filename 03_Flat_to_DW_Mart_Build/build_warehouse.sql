-- duckdb flat_to_mart.duckdb ".read build_warehouse.sql"

-- Step 0: Load data from cloud storage
.read 00_load_data.sql

-- Step 1: Create tables for star schema
.read 01_create_tables.sql

-- Step 2: Populate company_dim table
.read 02_populate_company_dim.sql

-- Step 3: Populate skills_dim table
.read 03_populate_skills_dim.sql

-- Step 4: Populate job_postings_fact table
.read 04_populate_fact_table.sql

-- Step 5: Populate skills_job_dim table
.read 05_populate_bridge_table.sql

-- Step 6: Verify schema
.read 06_verify_schema.sql