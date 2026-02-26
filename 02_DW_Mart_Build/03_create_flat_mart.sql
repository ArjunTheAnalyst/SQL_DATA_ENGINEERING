-- Step 3: Mart - Create flat mart table

DROP SCHEMA IF EXISTS flat_mart CASCADE;
-- (Using CASCADE to drop all dependents)

CREATE SCHEMA flat_mart;

SELECT '=== Loading flat mart ===' AS info;

CREATE OR REPLACE TABLE flat_mart.job_postings AS
SELECT
    a.job_id, a.job_title_short, a.job_title, 
    a.job_location, a.job_via, a.job_schedule_type, 
    a.job_work_from_home, a.search_location, a.job_posted_date, 
    a.job_no_degree_mention, a.job_health_insurance, 
    a.job_country, a.salary_rate, a.salary_year_avg, a.salary_hour_avg,

    a.company_id,
    b.name,

-- since we require one row per job with all the skills in an array, we will not include skill_id in SELECT
    -- c.skill_id,

-- Aggregate skills into an array of structs
    ARRAY_AGG(
        STRUCT_PACK(type := d.type, name := d.skills)
    ) AS skills_and_types
FROM
    job_postings_fact AS a
LEFT JOIN
    company_dim AS b
ON
    a.company_id = b.company_id
LEFT JOIN
    skills_job_dim AS c
ON
    a.job_id = c.job_id
LEFT JOIN
    skills_dim AS d
ON
    c.skill_id = d.skill_id
GROUP BY
    a.job_id, a.company_id, a.job_title_short, a.job_title, 
    a.job_location, a.job_via, a.job_schedule_type, 
    a.job_work_from_home, a.search_location, a.job_posted_date, 
    a.job_no_degree_mention, a.job_health_insurance, 
    a.job_country, a.salary_rate, a.salary_year_avg, a.salary_hour_avg,

    b.name;

-- Verify whether the data was loaded correctly
SELECT
    'flat_mart.job_postings' AS table_name,
    COUNT(*) AS record_cnt
FROM
    flat_mart.job_postings;

-- Sample data
SELECT '=== flat mart sample ===' AS info;
SELECT * FROM flat_mart.job_postings LIMIT 10;

/* 
Alternatively, you can use: 
duckdb flat_mart.duckdb -c ".read 03_create_flat_mart.sql" 
instead of creating a new schema, to prevent having 
a bunch of DuckDB files at the end of this.
*/