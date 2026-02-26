# Data Engineer Skills Analysis - EDA Project

![EDA](../Resources\01_Project1_EDA.png)

## 📊 Project Overview
This project performs exploratory data analysis on job postings for Data Engineer positions, focusing on remote work opportunities. The analysis identifies in-demand skills, salary trends, and optimal skill combinations for remote Data Engineer roles.

## 🎯 Key Objectives
1. **Top Skills Identification**: Identify the most frequently required skills for remote Data Engineer positions
2. **Salary Analysis**: Analyze salary trends associated with different technical skills
3. **Optimal Skills**: Determine skills that offer the best balance of demand and salary potential

## 🛠️ Tools & Technologies
- **Database**: MotherDuck (Cloud DuckDB)
- **Query Tool**: VS Code with DuckDB extension
- **Analysis**: SQL for data extraction and transformation
- **Version Control**: Git/GitHub

## 📁 Data Source
The analysis uses job postings data accessed through MotherDuck, with the following key tables:
- `job_postings_fact` - Main fact table containing job details
- `skills_dim` - Dimension table with skill names and IDs
- `skills_job_dim` - Bridge table linking jobs to skills
- `company_dim` - Dimension table with company information

## 🔍 Key Insights
### 💡 Most In-Demand Skills
1. SQL and Python dominate as the foundational skills for Data Engineers
2. Cloud platforms (AWS, Azure, GCP) are essential, with AWS leading
3. Big data technologies (Spark, Kafka, Snowflake) show strong demand
4. Orchestration tools like Airflow are increasingly important

### 💰 Highest-Paying Skills
1. Niche/lower-level languages (Rust, Golang) command premium salaries
2. Infrastructure as Code (Terraform) shows both high demand and high pay
3. Modern data stack (Snowflake, Databricks) offers competitive salaries
4. Kafka and Airflow prove that streaming/orchestration skills pay well

### 🎯 Optimal Skills to Learn
1. Based on the optimal score (balancing demand × salary):
2. Terraform - High demand + excellent salary
3. Python/SQL - Highest demand + good salary
4. AWS/Airflow/Spark - Strong demand + above-average salary
5. Kafka/Snowflake - Growing demand + strong salary potential