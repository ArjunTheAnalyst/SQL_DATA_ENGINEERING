-- Step 2: Data Warehouse - Load data from CSV files into star schema tables

-- Load company_dim table
SELECT '=== Loading company_dim ===' AS info;

INSERT INTO company_dim
(company_id, name)
SELECT
    company_id,
    name
FROM
    read_csv('https://storage.googleapis.com/sql_de/company_dim.csv', AUTO_DETECT = TRUE);

-- Load skills_dim table
SELECT '=== Loading skills_dim ===' AS info;

INSERT INTO skills_dim 
(skill_id, skills, type)
SELECT
    skill_id,
    skills, 
    type
FROM
    read_csv('https://storage.googleapis.com/sql_de/skills_dim.csv', AUTO_DETECT = TRUE);

-- Load job_postings_fact table
SELECT '=== Loading job_postings_fact ===' AS info;

INSERT INTO job_postings_fact 
(job_id, company_id, job_title_short, job_title, 
job_location, job_via, job_schedule_type, 
job_work_from_home, search_location, job_posted_date, 
job_no_degree_mention, job_health_insurance, 
job_country, salary_rate, salary_year_avg, salary_hour_avg)
SELECT
    job_id, 
    company_id, 
    job_title_short, 
    job_title, 
    job_location, 
    job_via, 
    job_schedule_type, 
    job_work_from_home, 
    search_location, 
    job_posted_date, 
    job_no_degree_mention, 
    job_health_insurance, 
    job_country, 
    salary_rate, 
    salary_year_avg, 
    salary_hour_avg
FROM
    read_csv('https://storage.googleapis.com/sql_de/job_postings_fact.csv', AUTO_DETECT = TRUE);

-- Load skills_job_dim table
SELECT '=== Loading skills_job_dim ===' AS info;

INSERT INTO skills_job_dim 
(job_id, skill_id)
SELECT
    job_id,
    skill_id
FROM
    read_csv('https://storage.googleapis.com/sql_de/skills_job_dim.csv', AUTO_DETECT = TRUE);

-- Verify whether the data was loaded correctly
SELECT
    'company_dim' AS table_name,
    COUNT(*) AS record_cnt
FROM
    company_dim

UNION ALL

SELECT
    'skills_dim' AS table_name,
    COUNT(*) AS record_cnt
FROM
    skills_dim

UNION ALL

SELECT
    'job_postings_fact' AS table_name,
    COUNT(*) AS record_cnt
FROM
    job_postings_fact

UNION ALL

SELECT
    'skills_job_dim' AS table_name,
    COUNT(*) AS record_cnt
FROM
    skills_job_dim;

-- Referential identity check (should return 0)
SELECT
    'orphaned company_ids in job_postings_fact' AS check_type,
    COUNT(company_id) AS orphaned_cnt
FROM
    job_postings_fact
WHERE
    company_id NOT IN (SELECT company_id FROM company_dim)

UNION ALL

SELECT
    'orphaned job_ids in skills_job_dim' AS check_type,
    COUNT(job_id) AS orphaned_cnt
FROM
    skills_job_dim
WHERE
    job_id NOT IN (SELECT job_id FROM job_postings_fact)

UNION ALL

SELECT
    'orphaned skill_ids in skills_job_dim' AS check_type,
    COUNT(skill_id) AS orphaned_cnt
FROM
    skills_job_dim
WHERE
    skill_id NOT IN (SELECT skill_id FROM skills_job_dim);

-- Sample data
SELECT '=== company_dim ===' AS info;
SELECT * FROM company_dim LIMIT 5;

SELECT '=== skills_dim ===' AS info;
SELECT * FROM skills_dim LIMIT 5;

SELECT '=== job_postings_fact ===' AS info;
SELECT * FROM job_postings_fact LIMIT 5;

SELECT '=== skills_job_dim ===' AS info;
SELECT * FROM skills_job_dim LIMIT 5;

-- P.S: Database - duckdb dw_marts.duckdb
