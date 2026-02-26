-- Step 5: Mart - Create priority roles mart (snapshot table)

DROP SCHEMA IF EXISTS priority_mart CASCADE;

CREATE SCHEMA priority_mart;

-- Create a lookup table that define which roles are 'priority'
CREATE TABLE priority_mart.priority_roles (
    role_id         INTEGER     PRIMARY KEY,
    role_name       VARCHAR,
    priority_lvl    INTEGER
);

INSERT INTO priority_mart.priority_roles
(role_id, role_name, priority_lvl)
VALUES  
    (1, 'Data Engineer', 2),
    (2, 'Senior Data Engineer', 1),
    (3, 'Software Engineer', 3);

-- Create priority_jobs_snapshot_table
CREATE TABLE priority_mart.priority_jobs_snapshot (
    job_id              INTEGER     PRIMARY KEY,
    job_title_short     VARCHAR,
    company_name        VARCHAR,
    job_posted_date     TIMESTAMP,
    salary_year_avg     DOUBLE,
    priority_lvl        INTEGER,
    updated_at          TIMESTAMP
);

INSERT INTO priority_mart.priority_jobs_snapshot
(job_id, job_title_short, company_name, job_posted_date, 
salary_year_avg, priority_lvl, updated_at)
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
All job postings are included regardless of whether or not 
they have a matching company record, and THEN only those jobs 
that match priority roles are inserted into the snapshot.
*/

-- Verify whether the data was loaded correctly
SELECT
    'priority_roles' AS table_name,
    COUNT(*) AS record_cnt
FROM
    priority_mart.priority_roles

UNION ALL

SELECT
    'priority_jobs_snapshot' AS table_name,
    COUNT(*) AS record_cnt
FROM
    priority_mart.priority_jobs_snapshot;

-- Sample data
SELECT '=== priority_roles ===' AS info;
SELECT * FROM priority_mart.priority_roles;

SELECT '=== priority_jobs_snapshot ===' AS info;
SELECT * FROM priority_mart.priority_jobs_snapshot LIMIT 5;

-- Summary
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
    job_cnt desc;
