-- Step 6: Verify schema

-- Verify record counts for all tables
SELECT 
    'company_dim' AS table_name,
    count(*) AS compan_dim_record_cnt
FROM
    company_dim

UNION ALL

SELECT
    'skills_dim' AS table_name,
    COUNT(*) AS skills_cnt
FROM
    skills_dim

UNION ALL

SELECT
    'job_postings_fact' AS table_name,
    COUNT(*) AS job_cnt
FROM
    job_postings_fact

UNION ALL

SELECT
    'skills_job_dim' AS table_name,
    COUNT(*) AS record_cnt
FROM
    skills_job_dim;

-- Sample data from each table
SELECT '=== company_dim ===' AS info;
SELECT * FROM company_dim LIMIT 5;

SELECT '=== skills_dim ===' AS info;
SELECT * FROM skills_dim LIMIT 5;

SELECT '=== job_postings_fact ===' AS info;
SELECT * FROM job_postings_fact LIMIT 5;

SELECT '=== skills_job_dim ===' AS info;
SELECT * FROM skills_job_dim LIMIT 5;

-- Join test
SELECT
    a.job_title,
    b.company_name,
    d.skills
FROM
    job_postings_fact AS a
INNER JOIN
    company_dim AS b
ON
    a.company_id = b.company_id
INNER JOIN
    skills_job_dim AS c
ON
    a.job_id = c.job_id
INNER JOIN
    skills_dim AS d
ON
    c.skill_id = d.skill_id
LIMIT 5;