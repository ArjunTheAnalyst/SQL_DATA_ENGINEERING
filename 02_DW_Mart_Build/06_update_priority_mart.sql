-- Step 6: Mart - Update priority roles mart (incremental update)
-- Run this only after Step 5

-- Update Existing Priority
UPDATE priority_mart.priority_roles
SET priority_lvl = 3
WHERE role_name = 'Data Engineer';

-- Add a new priority role
INSERT INTO priority_mart.priority_roles
(role_id, role_name, priority_lvl)
VALUES  
    (4, 'Data Scientist', 2),
    (5, 'Data Analyst', 4);

-- Create a temporary snapshot of what the correct table should look like based on the updated rules
CREATE OR REPLACE TEMP TABLE src_priority_jobs AS
SELECT
    a.job_id,
    a.job_title_short,
    b.name AS company_name,
    a.job_posted_date,
    a.salary_year_avg,
    c.priority_lvl,
    CURRENT_TIMESTAMP AS updated_at
FROM
    job_postings_fact AS a
LEFT JOIN
    company_dim AS b
ON
    a.company_id = b.company_id
INNER JOIN
    priority_mart.priority_roles AS c
ON
    a.job_title_short = c.role_name;

/*
MERGE Operation (Heart of the Process)
This MERGE statement handles:
1. WHEN MATCHED: Jobs in both tables
2. WHEN NOT MATCHED: New Jobs
3. WHEN NOT MATCHED BY SOURCE: Removed jobs
*/

MERGE INTO priority_mart.priority_jobs_snapshot AS tgt
USING src_priority_jobs AS src
ON tgt.job_id = src.job_id

WHEN MATCHED AND tgt.priority_lvl IS DISTINCT FROM src.priority_lvl THEN
UPDATE SET
    priority_lvl = src.priority_lvl,
    updated_at = src.updated_at

WHEN NOT MATCHED THEN
INSERT -- these columns are part of the target table
(job_id, job_title_short, company_name, job_posted_date, 
salary_year_avg, priority_lvl, updated_at)
VALUES 
(src.job_id, src.job_title_short, src.company_name, src.job_posted_date, 
src.salary_year_avg, src.priority_lvl, src.updated_at)

WHEN NOT MATCHED BY SOURCE THEN DELETE;

-- Verify whether the data was loaded correctly
SELECT
    'priority_mart.priority_roles' AS table_name,
    COUNT(*) AS record_cnt
FROM
    priority_mart.priority_roles

UNION ALL

SELECT
    'priority_mart.priority_jobs_snapshot' AS table_name,
    COUNT(*) AS record_cnt
FROM
    priority_mart.priority_jobs_snapshot;

-- Sample data
SELECT '=== priority_mart.priority_roles ===' AS info;
SELECT * FROM priority_mart.priority_roles;

SELECT '=== priority_mart.priority_jobs_snapshot ===' AS info;
SELECT * FROM priority_mart.priority_jobs_snapshot LIMIT 5;

-- Summary
SELECT '=== Priority Jobs Snapshot Sample ===' AS info;
SELECT
    job_title_short,
    COUNT(job_id) AS job_cnt,
    MIN(priority_lvl) AS priority_lvl,
    MIN(updated_at) AS updated_at
FROM
    priority_mart.priority_jobs_snapshot
GROUP BY
    job_title_short
ORDER BY
    job_cnt DESC;