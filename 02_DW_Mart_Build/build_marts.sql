-- duckdb dw_marts.duckdb ".read build_marts.sql"

-- Step 1: Data Warehouse - Create star schema tables
.read 01_create_tables_dw.sql

-- Step 2: Data Warehouse - Load data from CSV files into star schema tables
.read 02_load_schema_dw.sql

-- Step 3: Mart - Create flat mart table
.read 03_create_flat_mart.sql

-- Step 4: Mart - Create skills demand mart table
.read 04_create_skills_mart.sql

-- Step 5: Mart - Create priority roles mart (snapshot table)
.read 05_create_priority_mart.sql

-- Step 6: Mart - Update priority roles mart (incremental update)
.read 06_update_priority_mart.sql

-- Step 7: Mart - Create company prospecting mart
.read 07_company_mart.sql

-- P.S: Make sure the terminal points to DW_Mart_Build folder