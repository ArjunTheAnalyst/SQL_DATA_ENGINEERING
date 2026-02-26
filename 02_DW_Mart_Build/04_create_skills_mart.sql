-- Step 4: Mart - Create skills demand mart table

-- This mart focuses on skills trend with clean additive measures

DROP SCHEMA IF EXISTS skills_mart CASCADE;

CREATE SCHEMA skills_mart;

-- Create dim_skill table
CREATE TABLE skills_mart.dim_skill (
    skill_id    INTEGER     PRIMARY KEY,
    skills      VARCHAR,
    type        VARCHAR
);


-- Load skills_mart.dim_skill table
SELECT '=== Loading skills_mart.dim_skill ===' AS info;

INSERT INTO skills_mart.dim_skill 
(skill_id, skills, type)
SELECT
    skill_id,
    skills,
    type
FROM
    skills_dim;

-- Create dim_date_month table
CREATE TABLE skills_mart.dim_date_month (
    month_start_date    DATE        PRIMARY KEY,
    year                INTEGER,
    month               INTEGER,
    quarter             INTEGER,
    quarter_name        VARCHAR,
    year_quarter        VARCHAR
);

-- Load skills_mart.dim_date_month table
SELECT '=== Loading skills_mart.dim_date_month ===' AS info;

INSERT INTO skills_mart.dim_date_month
(month_start_date, year, month, quarter, quarter_name, year_quarter)
SELECT DISTINCT
    DATE_TRUNC('month',job_posted_date) AS month_start_date,
    EXTRACT(YEAR FROM job_posted_date) AS year,
    EXTRACT(MONTH FROM job_posted_date) AS month,
    EXTRACT(QUARTER FROM job_posted_date) AS quarter,
    'Q-'|| EXTRACT(QUARTER FROM job_posted_date)::VARCHAR AS quarter_name,
    EXTRACT(YEAR FROM job_posted_date)::VARCHAR || '-Q' || EXTRACT(QUARTER FROM job_posted_date)::VARCHAR AS year_quarter
FROM
    job_postings_fact
ORDER BY
    month_start_date;

-- Create fact_skill_demand_monthly
CREATE TABLE skills_mart.fact_skill_demand_monthly(
    skill_id                            INTEGER,
    month_start_date                    DATE,
    job_title_short                     VARCHAR,
    postings_count                      INTEGER,
    remote_postings_count               INTEGER,
    health_insurance_postings_count     INTEGER,
    no_degree_mention_postings_count    INTEGER,
    PRIMARY KEY (skill_id, month_start_date, job_title_short),
    FOREIGN KEY (skill_id)          REFERENCES skills_mart.dim_skill(skill_id),
    FOREIGN KEY (month_start_date)  REFERENCES skills_mart.dim_date_month(month_start_date)
);

-- Load skills_mart.fact_skill_demand_monthly table
SELECT '=== Loading skills_mart.fact_skill_demand_monthly ===' AS info;

INSERT INTO skills_mart.fact_skill_demand_monthly
(skill_id, month_start_date, job_title_short, postings_count,
remote_postings_count, health_insurance_postings_count, no_degree_mention_postings_count)

WITH job_postings_prep AS
(SELECT
    b.skill_id,
    DATE_TRUNC('month', a.job_posted_date) AS month_start_date,
    a.job_title_short,
    a.job_id,
    CASE WHEN job_work_from_home = TRUE then 1 else 0 END AS remote_posting,
    CASE WHEN job_health_insurance = TRUE then 1 else 0 END AS health_insurance_posting,
    CASE WHEN job_no_degree_mention = TRUE then 1 else 0 END AS no_degree_mention_posting
FROM
    job_postings_fact AS a
INNER JOIN -- only looking at jobs with associated skills
    skills_job_dim AS b
ON
    a.job_id = b.job_id)

SELECT
    skill_id,
    month_start_date,
    job_title_short,
    COUNT(job_id) AS postings_count,
    SUM(remote_posting) AS remote_postings_count,
    SUM(health_insurance_posting) AS health_insurance_postings_count,
    SUM(no_degree_mention_posting) AS no_degree_mention_postings_count
FROM
    job_postings_prep
GROUP BY
    skill_id,
    month_start_date,
    job_title_short
ORDER BY
    skill_id,
    month_start_date,
    job_title_short;

-- Verify whether the data was loaded correctly
SELECT
    'dim_skill' AS table_name,
    COUNT(*) AS record_cnt
FROM
    skills_mart.dim_skill

UNION ALL

SELECT
    'dim_date_month' AS table_name,
    COUNT(*) AS record_cnt
FROM
    skills_mart.dim_date_month

UNION ALL

SELECT
    'fact_skill_demand_monthly' AS table_name,
    COUNT(*) AS record_cnt
FROM
    skills_mart.fact_skill_demand_monthly;

-- Sample data
SELECT '=== dim_skill ===' AS info;
SELECT * FROM skills_mart.dim_skill LIMIT 5;

SELECT '=== dim_date_month ===' AS info;
SELECT * FROM skills_mart.dim_date_month LIMIT 5;

SELECT '=== fact_skill_demand_monthly ===' AS info;
SELECT * FROM skills_mart.fact_skill_demand_monthly LIMIT 5;

