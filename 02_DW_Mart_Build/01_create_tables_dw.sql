-- Step 1: Data Warehouse - Create star schema tables

-- Drop existing tables if they exist (for idempotency)
DROP TABLE IF EXISTS skills_job_dim;
DROP TABLE IF EXISTS job_postings_fact;
DROP TABLE IF EXISTS company_dim;
DROP TABLE IF EXISTS skills_dim;

-- Create company_dim table (must be created before job_postings_fact)
CREATE TABLE company_dim (
    company_id  INTEGER     PRIMARY KEY,
    name        VARCHAR
);

-- Create skills_dim table (must be created before skills_job_dim)
CREATE TABLE skills_dim (
    skill_id   INTEGER     PRIMARY KEY,
    skills     VARCHAR,
    type       VARCHAR
);

-- Create job_postings_fact table
CREATE TABLE job_postings_fact (
    job_id                  INTEGER     PRIMARY KEY,
    company_id              INTEGER,
    job_title_short         VARCHAR,
    job_title               VARCHAR,
    job_location            VARCHAR,
    job_via                 VARCHAR,
    job_schedule_type       VARCHAR,
    job_work_from_home      BOOLEAN,
    search_location         VARCHAR,
    job_posted_date         TIMESTAMP,
    job_no_degree_mention   BOOLEAN,
    job_health_insurance    BOOLEAN,
    job_country             VARCHAR,
    salary_rate             VARCHAR,
    salary_year_avg         DOUBLE,
    salary_hour_avg         DOUBLE,
    FOREIGN KEY (company_id) REFERENCES company_dim(company_id)
);

-- Create skills_job_dim table
CREATE TABLE skills_job_dim (
    job_id      INTEGER,
    skill_id    INTEGER,
    PRIMARY KEY (job_id, skill_id), -- composite primary key
    FOREIGN KEY (job_id)    REFERENCES job_postings_fact(job_id),
    FOREIGN KEY (skill_id)  REFERENCES skills_dim(skill_id)
);


-- Verify if tables were created
SELECT
    table_name
FROM
    information_schema.tables
WHERE
    table_schema = 'main';

/*
1. Primary Key uniquely identifies each row in a table, where as,
a Foreign Key links one table to another by using the Primary Key of
another table.

2. A composite primary key uses multiple columns as a unique
identifier when one column isn't enough.

3. Idempotency refers to the concept of running the 
same operation multiple times produces the same result 
just as running it once.

4. Order of dependencies during creation, deletion and insertion
CREATION : PARENT -> CHILD
DELETION: CHILD -> PARENT
INSERTION: PARENT -> CHILD

5. Referential integrity check ensures each value in the
child table's foreign key column has a matching value 
in the parent table's primary key column.

6. Schema Check: SELECT * FROM INFORMATION_SCHEMA.SCHEMATA;

7. Database Check: SELECT CURRENT_DATABASE();
*/