-- Step 4: Populate job_postings_fact table

INSERT INTO job_postings_fact 
(job_id, company_id, job_title_short, job_title, 
job_location, job_via, job_schedule_type, 
job_work_from_home, search_location, job_posted_date, 
job_no_degree_mention, job_health_insurance, 
job_country, salary_rate, salary_year_avg, salary_hour_avg)

SELECT
    ROW_NUMBER() OVER(ORDER BY a.job_posted_date) AS job_id,
    b.company_id,
    a.job_title_short, 
    a.job_title, 
    a.job_location, 
    a.job_via, 
    a.job_schedule_type, 
    a.job_work_from_home, 
    a.search_location, 
    a.job_posted_date, 
    a.job_no_degree_mention, 
    a.job_health_insurance, 
    a.job_country, 
    a.salary_rate, 
    a.salary_year_avg, 
    a.salary_hour_avg
FROM
    job_postings AS a
LEFT JOIN
    company_dim AS b
ON
    a.company_name = b.company_name;

-- Verify whether the data was loaded correctly
SELECT
    COUNT(*) AS job_cnt
FROM
    job_postings_fact;

-- Sample data
SELECT
    *
FROM
    job_postings_fact
LIMIT 5;