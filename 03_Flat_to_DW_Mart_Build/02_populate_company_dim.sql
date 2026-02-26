-- Step 2: Populate company_dim table

INSERT INTO company_dim
(company_id, company_name)

WITH distinct_companies AS
(SELECT DISTINCT
    company_name
FROM
    job_postings
WHERE
    company_name IS NOT NULL)
SELECT
    ROW_NUMBER() OVER(ORDER BY company_name) AS company_id,
    company_name
FROM
    distinct_companies;

-- Verify whether the data was loaded correctly
SELECT
    count(*) AS compan_dim_record_cnt
FROM
    company_dim;

-- Sample data
SELECT
    *
FROM
    company_dim
LIMIT 5;
