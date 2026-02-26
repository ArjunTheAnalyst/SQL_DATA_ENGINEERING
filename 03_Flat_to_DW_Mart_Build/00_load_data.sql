-- Step 0: Load data from cloud storage

DROP TABLE IF EXISTS job_postings;

-- Create the initial job postings table
CREATE TABLE job_postings (
    job_title_short         VARCHAR,
    job_title               VARCHAR,
    job_location            VARCHAR,
    job_via                 VARCHAR,
    job_schedule_type       VARCHAR,
    job_work_from_home      VARCHAR,
    search_location         VARCHAR,
    job_posted_date         TIMESTAMP,
    job_no_degree_mention   BOOLEAN,
    job_health_insurance    BOOLEAN,
    job_country             VARCHAR,
    salary_rate             VARCHAR,
    salary_year_avg         DOUBLE,
    salary_hour_avg         DOUBLE,
    company_name            VARCHAR,
    job_skills              VARCHAR,
    job_type_skills         VARCHAR
);

INSERT INTO job_postings
(job_title_short, job_title, job_location, job_via,
job_schedule_type, job_work_from_home, search_location,
job_posted_date, job_no_degree_mention, job_health_insurance,
job_country, salary_rate, salary_year_avg, salary_hour_avg,
company_name, job_skills, job_type_skills)

SELECT
    *
FROM
    read_csv('https://storage.googleapis.com/sql_de/job_postings_flat.csv', AUTO_DETECT = TRUE);

-- Verify whether the data was loaded correctly
SELECT
    COUNT(*) AS total_records
FROM
    job_postings;

-- Sample data
SELECT
    *
FROM
    job_postings
LIMIT 5;