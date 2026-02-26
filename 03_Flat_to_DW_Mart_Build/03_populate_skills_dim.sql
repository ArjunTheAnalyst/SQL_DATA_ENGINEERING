-- Step 3: Populate skills_dim table

INSERT INTO skills_dim 
(skill_id, skills)

WITH distinct_skills AS
(SELECT DISTINCT
    TRIM(
        UNNEST(    
            STRING_SPLIT(
                REPLACE(
                    REPLACE(
                        REPLACE(job_skills,'[',''), 
                    ']',''), 
                '''','') -- replacing 'sql' with sql
            , ',') -- string_split converts a string into an array
            )
    ) AS skills
FROM
    job_postings) -- job_skills does not contain any null values
SELECT
    ROW_NUMBER() OVER(ORDER BY skills) AS skill_id,
    skills
FROM
    distinct_skills;

-- Verify whether the data was loaded correctly
SELECT
    COUNT(*) AS skills_cnt
FROM
    skills_dim;

-- Sample data
SELECT
    *
FROM
    skills_dim
LIMIT 5;