-- Step 7: Mart - Create company prospecting mart

-- This mart focuses on hiring trends

DROP SCHEMA IF EXISTS company_mart CASCADE;

CREATE SCHEMA company_mart;

-- Create dim_job_title_short table
CREATE TABLE company_mart.dim_job_title_short (
    job_title_short_id  INTEGER     PRIMARY KEY,
    job_title_short     VARCHAR
);

INSERT INTO company_mart.dim_job_title_short
(job_title_short_id, job_title_short)

WITH distinct_title_shorts AS
(SELECT
    DISTINCT job_title_short
FROM
    job_postings_fact
WHERE
    job_title_short IS NOT NULL)
SELECT
    ROW_NUMBER() OVER(ORDER BY job_title_short) 
    AS job_title_short_id,
    job_title_short
FROM
    distinct_title_shorts;

-- Create dim_job_title table
CREATE TABLE company_mart.dim_job_title (
    job_title_id    INTEGER     PRIMARY KEY,
    job_title       VARCHAR
);

INSERT INTO company_mart.dim_job_title
(job_title_id, job_title)

WITH distinct_job_titles AS
(SELECT
    DISTINCT job_title
FROM
    job_postings_fact
WHERE
    job_title IS NOT NULL)
SELECT
    ROW_NUMBER() OVER(ORDER BY job_title) 
    AS job_title_id,
    job_title
FROM
    distinct_job_titles;

-- Create dim_company table
CREATE TABLE company_mart.dim_company (
    company_id      INTEGER     PRIMARY KEY,
    company_name    VARCHAR
);

INSERT INTO company_mart.dim_company
(company_id, company_name)
SELECT
    company_id,
    name AS company_name
FROM
    company_dim;

-- Create dim_location table
CREATE TABLE company_mart.dim_location (
    location_id     INTEGER     PRIMARY KEY,
    job_country     VARCHAR,
    job_location    VARCHAR
);

INSERT INTO company_mart.dim_location
(location_id, job_country, job_location)

WITH distinct_locations AS
(SELECT DISTINCT
    job_country,
    job_location
FROM
    job_postings_fact
WHERE
    job_country IS NOT NULL
AND
    job_location IS NOT NULL)
SELECT
    ROW_NUMBER() OVER(ORDER BY job_country, job_location)
    AS location_id,
    job_country,
    job_location
FROM
    distinct_locations;

-- Create dim_date_month table
CREATE TABLE company_mart.dim_date_month (
    month_start_date    DATE    PRIMARY KEY,
    year                INTEGER,
    month               INTEGER
);

INSERT INTO company_mart.dim_date_month
(month_start_date, year, month)

SELECT DISTINCT
    DATE_TRUNC('month', job_posted_date) AS month_start_date,
    EXTRACT(YEAR FROM job_posted_date) AS year,
    EXTRACT(month FROM job_posted_date) AS month
FROM
    job_postings_fact;

-- Create bridge_job_title
-- Shows all possible job_title variations for each job_title_short
CREATE TABLE company_mart.bridge_job_title (
    job_title_short_id  INTEGER,
    job_title_id        INTEGER,
    PRIMARY KEY (job_title_short_id, job_title_id),
    FOREIGN KEY (job_title_short_id)    REFERENCES company_mart.dim_job_title_short(job_title_short_id),
    FOREIGN KEY (job_title_id)          REFERENCES company_mart.dim_job_title(job_title_id)
);

INSERT INTO company_mart.bridge_job_title
(job_title_short_id, job_title_id)

SELECT DISTINCT
    b.job_title_short_id,
    c.job_title_id
FROM
    job_postings_fact AS a
INNER JOIN
    company_mart.dim_job_title_short AS b
ON
    a.job_title_short = b.job_title_short
INNER JOIN
    company_mart.dim_job_title AS c
ON
    a.job_title = c.job_title
WHERE
    a.job_title_short IS NOT NULL
AND
    a.job_title IS NOT NULL;

-- Create bridge_company_location
CREATE TABLE company_mart.bridge_company_location (
    company_id      INTEGER,
    location_id     INTEGER,
    PRIMARY KEY (company_id, location_id),
    FOREIGN KEY (company_id)    REFERENCES company_mart.dim_company(company_id),
    FOREIGN KEY (location_id)   REFERENCES company_mart.dim_location(location_id)
);

INSERT INTO company_mart.bridge_company_location
(company_id, location_id)

SELECT DISTINCT
    a.company_id,
    b.location_id
FROM
    job_postings_fact AS a
INNER JOIN
    company_mart.dim_location AS b
ON
    a.job_country = b.job_country
AND
    a.job_location = b.job_location;

-- Create fact_company_hiring_monthly
CREATE TABLE company_mart.fact_company_hiring_monthly (
    company_id              INTEGER,
    job_title_short_id      INTEGER,
    month_start_date        DATE,
    job_country             VARCHAR,
    postings_count          INTEGER,
    median_salary_year      DOUBLE,
    min_salary_year         DOUBLE,
    max_salary_year         DOUBLE,
    remote_share            DOUBLE,
    health_insurance_share  DOUBLE,
    no_degree_mention_share DOUBLE,
    PRIMARY KEY (company_id, job_title_short_id, month_start_date, job_country),
    FOREIGN KEY(company_id)         REFERENCES company_mart.dim_company(company_id),
    FOREIGN KEY(job_title_short_id) REFERENCES company_mart.dim_job_title_short(job_title_short_id),
    FOREIGN KEY(month_start_date)   REFERENCES company_mart.dim_date_month(month_start_date)
);

INSERT INTO company_mart.fact_company_hiring_monthly
(company_id, job_title_short_id, month_start_date, job_country,
postings_count, median_salary_year, min_salary_year, max_salary_year,
remote_share, health_insurance_share,
no_degree_mention_share)

WITH job_postings_prep AS
(SELECT
    a.company_id,
    b.job_title_short_id,
    DATE_TRUNC('month',a.job_posted_date) AS month_start_date,
    a.job_country,
    a.job_id,
    a.salary_year_avg,

-- Convert boolean format to numeric values
    CASE WHEN a.job_work_from_home = TRUE THEN 1 ELSE 0 END AS is_remote,
    CASE WHEN a.job_health_insurance = TRUE THEN 1 ELSE 0 END AS hAS_health_insurance,
    CASE WHEN a.job_no_degree_mention = TRUE THEN 1 ELSE 0 END AS no_degree_required
FROM
    job_postings_fact AS a
INNER JOIN
    company_mart.dim_job_title_short AS b
ON
    a.job_title_short = b.job_title_short
WHERE
    a.job_country IS NOT NULL

-- neither column (company_id and job_posted_date) contain null values
)
SELECT
    company_id,
    job_title_short_id,
    month_start_date,
    job_country,
    COUNT(job_id) AS postings_count,
    MEDIAN(salary_year_avg) AS median_salary_year,
    MIN(salary_year_avg) AS min_salary_year,
    MAX(salary_year_avg) AS max_salary_year,
    
    -- ratio of remote friendly job postings in this group
    AVG(is_remote) AS remote_share,
    
    -- ratio of postings that offer health insurance
    AVG(hAS_health_insurance) AS health_insurance_share,

    -- ratio of postings that negate a degree
    AVG(no_degree_required) AS no_degree_mention_share
FROM
    job_postings_prep
GROUP BY
    company_id,
    job_title_short_id,
    month_start_date,
    job_country;

-- Verify whether the data was loaded correctly
SELECT
    'company_mart.dim_job_title_short' AS table_name,
    COUNT(*) AS record_cnt
FROM
    company_mart.dim_job_title_short

UNION ALL

SELECT
    'company_mart.dim_job_title' AS table_name,
    COUNT(*) AS record_cnt
FROM
    company_mart.dim_job_title

UNION ALL

SELECT
    'company_mart.dim_company' AS table_name,
    COUNT(*) AS record_cnt
FROM
    company_mart.dim_company

UNION ALL

SELECT
    'company_mart.dim_location' AS table_name,
    COUNT(*) AS record_cnt
FROM
    company_mart.dim_location

UNION ALL

SELECT
    'company_mart.dim_date_month' AS table_name,
    COUNT(*) AS record_cnt
FROM
    company_mart.dim_date_month

UNION ALL

SELECT
    'company_mart.bridge_job_title' AS table_name,
    COUNT(*) AS record_cnt
FROM
    company_mart.bridge_job_title

UNION ALL

SELECT
    'company_mart.bridge_company_location' AS table_name,
    COUNT(*) AS record_cnt
FROM
    company_mart.bridge_company_location

UNION ALL

SELECT
    'company_mart.fact_company_hiring_monthly' AS table_name,
    COUNT(*) AS record_cnt
FROM
    company_mart.fact_company_hiring_monthly;

-- Sample data
SELECT '=== company_mart.dim_job_title_short ===' AS info;
SELECT * FROM company_mart.dim_job_title_short LIMIT 10;

SELECT '=== company_mart.dim_job_title ===' AS info;
SELECT * FROM company_mart.dim_job_title LIMIT 10;

SELECT '=== company_mart.dim_company ===' AS info;
SELECT * FROM company_mart.dim_company LIMIT 10;

SELECT '=== company_mart.dim_location ===' AS info;
SELECT * FROM company_mart.dim_location LIMIT 10;

SELECT '=== company_mart.dim_date_month ===' AS info;
SELECT * FROM company_mart.dim_date_month ORDER BY month_start_date DESC LIMIT 10;

SELECT '=== company_mart.bridge_job_title ===' AS info;
SELECT * FROM company_mart.bridge_job_title LIMIT 10;

SELECT '=== company_mart.bridge_company_location ===' AS info;
SELECT * FROM company_mart.bridge_company_location LIMIT 10;

SELECT '=== company_mart.fact_company_hiring_monthly ===' AS info;
SELECT * FROM company_mart.fact_company_hiring_monthly LIMIT 10;

SELECT '=== Company Location Bridge Sample ===' AS info;
SELECT
    a.company_id,
    b.company_name,
    a.location_id,
    c.job_country,
    c.job_location
FROM
    company_mart.bridge_company_location AS a
INNER JOIN
    company_mart.dim_company AS b
ON
    a.company_id = b.company_id
INNER JOIN
    company_mart.dim_location AS c
ON
    a.location_id = c.location_id
LIMIT 10;

SELECT '=== Job Title Bridge Sample ===' AS info;
SELECT
    a.job_title_short_id,
    b.job_title_short,
    a.job_title_id,
    c.job_title
FROM
    company_mart.bridge_job_title AS a
INNER JOIN
    company_mart.dim_job_title_short AS b
ON
    a.job_title_short_id = b.job_title_short_id
INNER JOIN
    company_mart.dim_job_title AS c
ON
    a.job_title_id = c.job_title_id
LIMIT 10;

SELECT '=== Company Hiring Fact Sample ===' AS info;
SELECT
    a.company_id,
    b.company_name,
    a.job_title_short_id,
    c.job_title_short,
    a.month_start_date,
    d.year,
    d.month,
    a.job_country,
    postings_count,
    median_salary_year,
    min_salary_year,
    max_salary_year,
    remote_share,
    health_insurance_share,
    no_degree_mention_share
FROM
    company_mart.fact_company_hiring_monthly AS a
INNER JOIN
    company_mart.dim_company AS b
ON
    a.company_id = b.company_id
INNER JOIN
    company_mart.dim_job_title_short AS c
ON
    a.job_title_short_id = c.job_title_short_id
INNER JOIN
    company_mart.dim_date_month AS d
ON
    a.month_start_date = d.month_start_date
ORDER BY
    postings_count DESC,
    median_salary_year DESC
LIMIT 10;