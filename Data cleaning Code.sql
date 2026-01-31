-- Data cleaning
select *
From layoffs;


-- Steps to clean this data
-- 1. check for duplicates and remove any
-- 2. standardize data and fix errors
-- 3. Look at null values and see what 
-- 4. remove any columns and rows that are not necessary - few ways

CREATE TABLE layoffs_staging
Like layoffs;

select *
From layoffs_staging;

Insert layoffs_staging
select *
From layoffs;

select *,
ROW_NUMBER()OVER(
Partition by company, industry, total_laid_off, percentage_laid_off, 'date') AS ROW_NUM
from layoffs_staging;

With duplicate_cte AS
(
select *,
ROW_NUMBER()OVER(
Partition by company,location,
 industry, total_laid_off, percentage_laid_off, 'date',stage,funds_raised_millions) AS ROW_NUM
from layoffs_staging
)
Select *
from duplicate_cte
where row_num>1;

Select *
from world_layoffs.layoffs_staging2
where company= 'casper';

CREATE TABLE `layoffs_staging` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `Row_num` text,
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE layoffs_staging2
like layoffs_staging;

select *
From layoffs_staging2;

insert layoffs_staging2
select *
from layoffs_staging;
 
 select *
 from layoffs_staging2
 where row_num>1;
 
With duplicate_cte AS
(
select *,
ROW_NUMBER()OVER(
Partition by company,location,
 industry, total_laid_off, percentage_laid_off, 'date',stage,funds_raised_millions) AS ROW_NUM
from world_layoffs.layoffs_staging2
)
Select *
from duplicate_cte
where row_num>1;


With duplicate_cte AS
(
select *,
ROW_NUMBER()OVER(
Partition by company,location,
 industry, total_laid_off, percentage_laid_off, 'date',stage,funds_raised_millions) AS ROW_NUM
from world_layoffs.layoffs_staging2
)
delete
from duplicate_cte
where ROW_NUM>1;

SELECT *
FROM world_layoffs.layoffs_staging2;

WITH cte AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY company, location, industry,
                            total_laid_off, percentage_laid_off,
                            `date`, stage, funds_raised_millions
               ORDER BY company
           ) AS row_num
    FROM world_layoffs.layoffs_staging2
)
SELECT COUNT(*) 
FROM cte
WHERE row_num > 1;

ALTER TABLE world_layoffs.layoffs_staging2
ADD COLUMN id BIGINT AUTO_INCREMENT PRIMARY KEY;

WITH duplicate_cte AS (
    SELECT id,
           ROW_NUMBER() OVER (
               PARTITION BY 
                   TRIM(LOWER(company)), 
                   TRIM(LOWER(location)),
                   TRIM(LOWER(industry)), 
                   total_laid_off, 
                   percentage_laid_off, 
                   `date`, 
                   TRIM(LOWER(stage)), 
                   funds_raised_millions
               ORDER BY id
           ) AS rn
    FROM world_layoffs.layoffs_staging2
)
DELETE FROM world_layoffs.layoffs_staging2
WHERE id IN (SELECT id FROM duplicate_cte WHERE rn > 1);

SELECT company, location, industry, total_laid_off,
       percentage_laid_off, `date`, stage, funds_raised_millions,
       COUNT(*) AS cnt
FROM world_layoffs.layoffs_staging2
GROUP BY company, location, industry, total_laid_off,
         percentage_laid_off, `date`, stage, funds_raised_millions
HAVING cnt > 1;


-- Standardizing data
SELECT company, (Trim(company))
from world_layoffs.layoffs_staging2;

UPDATE world_layoffs.layoffs_staging2
SET company =  Trim(company);

select distinct industry
from world_layoffs.layoffs_staging2
order by 1;

select *
from layoffs_staging2
where industry like 'crypto%';

update  world_layoffs.layoffs_staging2
SET industry = 'crypto'
where industry like 'crypto%';

SELECT distinct country, trim(trailing ',' from country)
from world_layoffs.layoffs_staging2
order by 1;

update world_layoffs.layoffs_staging2
set country = trim(trailing ',' from country)
where country like 'united states%';

select date,
STR_TO_DATE(date,'%m/%d/%Y') 
from layoffs_staging2;

ALTER TABLE world_layoffs.layoffs_staging2
MODIFY COLUMN date DATE;

Update world_layoffs.layoffs_staging2
set date = STR_TO_DATE(date,'%m/%d/%Y');

select *
from world_layoffs.layoffs_staging2
where total_laid_off is Null
and percentage_laid_off is Null;

Delete
from layoffs_staging2
where total_laid_off is Null
and percentage_laid_off is Null;

select *
from world_layoffs.layoffs_staging2;

select *
from world_layoffs.layoffs_staging2
where industry is Null
or industry = '';

select *
from world_layoffs.layoffs_staging2
where company like'ballys%';

SELECT 
    t1.company,
    t1.location,
    t1.industry AS null_industry,
    t2.industry AS source_industry
FROM world_layoffs.layoffs_staging2 t1
JOIN world_layoffs.layoffs_staging2 t2
  ON t1.company = t2.company
WHERE t1.industry IS NULL
  AND t2.industry IS NOT NULL;
 
 SELECT
    t1.location,
    t1.industry,
    t2.industry
FROM world_layoffs.layoffs_staging2 t1
JOIN world_layoffs.layoffs_staging2 t2
  ON t1.location = t2.location
WHERE t1.industry IS NULL
  AND t2.industry IS NOT NULL;

UPDATE world_layoffs.layoffs_staging2 t1
JOIN world_layoffs.layoffs_staging2 t2
  ON t1.location = t2.location
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
  AND t2.industry IS NOT NULL;
SELECT ROW_COUNT();

UPDATE world_layoffs.layoffs_staging2 t1
JOIN (
    SELECT company, MAX(industry) AS industry
    FROM world_layoffs.layoffs_staging2
    WHERE industry IS NOT NULL
    GROUP BY company
) t2
ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL;

SELECT DISTINCT company
FROM world_layoffs.layoffs_staging2
WHERE industry IS NULL;

UPDATE world_layoffs.layoffs_staging2
SET industry = 'Unknown'
WHERE industry IS NULL;

SELECT
  industry,
  industry IS NULL AS is_null,
  LENGTH(industry) AS len,
  HEX(industry) AS hex_value
FROM world_layoffs.layoffs_staging2
WHERE industry IS NULL
   OR industry = ''
   OR TRIM(industry) = ''
LIMIT 20;

SHOW VARIABLES LIKE 'sql_safe_updates';
SET SQL_SAFE_UPDATES = 0;

UPDATE world_layoffs.layoffs_staging2
SET industry = 'Unknown'
WHERE industry IS NULL;
SELECT ROW_COUNT();

DELETE
FROM world_layoffs.layoffs_staging2
WHERE company IS NULL
  AND location IS NULL
  AND industry IS NULL
  AND total_laid_off IS NULL
  AND percentage_laid_off IS NULL
  AND `date` IS NULL
  AND stage IS NULL
  AND country IS NULL
  AND funds_raised_millions IS NULL
  AND id IS NULL;
  SELECT ROW_COUNT();

ALTER TABLE layoffs_staging2
DROP column row_num;




