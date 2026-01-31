# Data-Cleaning-project
## Executive Summary

This project demonstrates an end-to-end, production-minded data cleaning workflow applied to a real-world layoffs dataset using SQL.

The objective was to transform a raw, inconsistent dataset into a reliable, analysis-ready data asset by addressing duplicates, missing values, formatting inconsistencies, and invalid records — challenges commonly encountered in business and analytics environments.

The project emphasizes:

1.Data integrity and reproducibility

2.Safe transformation practices

3.Scalable SQL techniques used in professional data teams
## Data Source
- **Raw Dataset:** [`layoffs.csv`](layoffs.csv)

## Core Skills Demonstrated

Production-minded SQL workflows

Data quality assurance

Window functions & CTEs

Defensive data cleaning techniques

Business-oriented data preparation

## Tools 

MySQL

Advanced SQL

  - Common Table Expressions (CTEs)
  - Window functions
  - String manipulation
  - Date transformations
  - Self-joins
  
## Dataset Overview
The dataset contains company layoff information, including:

i)Company name

ii)Location

iii)Industry

iv)Total layoffs

v)Percentage laid off

vi)Date

vii)Company stage

viii)Country

ix)Funds raised

## Business Problem
Raw operational datasets often suffer from:

1.Duplicate records

2.Inconsistent text formatting

3.Missing or incomplete values

4.Invalid or non-informative records

If left unresolved, these issues can distort insights, break dashboards, and undermine business decisions.
This project simulates a real analytics scenario where a data analyst is responsible for preparing trusted data for downstream analysis and reporting.
Dataset Overview
## Data Cleaning Methodology

*1. Data Isolation via Staging Tables*

A dedicated staging table was created to ensure:

- Raw data preservation

- Safe, auditable transformations

- Reproducibility of the cleaning process

```sql
CREATE TABLE layoffs_staging LIKE layoffs;
INSERT INTO layoffs_staging
SELECT *
FROM layoffs;
```

This mirrors best practices in production data pipelines and prevents irreversible data loss.

*2. Duplicate Detection & Resolution*

Duplicates were identified using a window function (ROW_NUMBER) across all relevant attributes

```sql
WITH duplicate_cte AS (
    SELECT *,
           ROW_NUMBER() OVER(
               PARTITION BY company, location, industry, total_laid_off,
                            percentage_laid_off, date, stage, country, funds_raised
           ) AS row_num
    FROM layoffs_staging
)
DELETE FROM duplicate_cte
WHERE row_num > 1;
```

#### Impact:

Ensured each record represents a unique business event

Prevented inflated metrics during analysis

*3. Text Standardization & Data Consistency*

Inconsistent text values were normalized to ensure accurate grouping and aggregation.
*Company names*
```sql
UPDATE layoffs_staging
SET company = TRIM(company);
```
*Industry normalization*

```sql
UPDATE layoffs_staging
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';
```

*Country formatting*
```sql
UPDATE layoffs_staging
SET country = TRIM(TRAILING '.' FROM country);
```

*4. Strategic NULL Handling*

Blank strings were converted to NULL, and missing values were populated using contextual inference.

```sql
UPDATE layoffs_staging
SET industry = NULL
WHERE industry = '';

UPDATE layoffs_staging t1
JOIN layoffs_staging t2
    ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
  AND t2.industry IS NOT NULL;
```

 *Approach:*

Filled missing values only where high-confidence matches existed

Avoided assumptions that could compromise data integrity

*5. Date Normalization*

Dates were standardized into proper SQL DATE format to support time-series analysis.

```sql
UPDATE layoffs_staging
SET date = STR_TO_DATE(date, '%m/%d/%Y');

ALTER TABLE layoffs_staging
MODIFY COLUMN date DATE;
```

*6. Removal of Non-Analytical Records*

Rows lacking both layoff count and percentage were removed.
```sql
DELETE FROM layoffs_staging
WHERE total_laid_off IS NULL
  AND percentage_laid_off IS NULL;
  ```

*Rationale:*
These records provided no analytical value and could introduce noise into reports.

*7. Final Schema Cleanup*

Temporary helper columns were dropped to maintain a clean final dataset.

```sql
ALTER TABLE layoffs_staging
DROP COLUMN row_num;
```
## Final Deliverable

The final dataset is:

- Fully deduplicated

- Standardized and validated

- Free from invalid or misleading records

- Ready for EDA, dashboarding, and reporting

This mirrors the quality expectations of analytics, BI, and data engineering teams









