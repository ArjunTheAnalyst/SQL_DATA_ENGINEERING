-- Step 5: Populate skills_job_dim table

INSERT INTO skills_job_dim
(job_id, skill_id)

WITH parsed_skills AS
(SELECT DISTINCT
    b.job_id,
    TRIM(skill.UNNEST) AS skill_name
/* 
skill.unnest is required because DuckDB wraps each unnested 
value in a struct with a default field named unnest
*/
FROM
    job_postings AS a
INNER JOIN
    job_postings_fact AS b
ON
    a.job_title = b.job_title
AND
    a.job_posted_date = b.job_posted_date
CROSS JOIN
    UNNEST(STRING_SPLIT(REPLACE(REPLACE(REPLACE(a.job_skills,'[',''),']',''),'''',''),','))
    AS skill)
SELECT
    job_id,
    sd.skill_id
FROM
    parsed_skills AS ps
INNER JOIN
    skills_dim AS sd
ON
    ps.skill_name = sd.skills;

-- Verify whether the data was loaded correctly
SELECT
    COUNT(*) AS record_cnt
FROM
    skills_job_dim;

-- Sample data
SELECT
    *
FROM
    skills_job_dim
LIMIT 5;