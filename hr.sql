-- Create database and import table
-- CREATE projects;
USE projects;
SELECT * FROM hr;

-- Data Cleaning
UPDATE hr
SET termdate = date(str_to_date(termdate,'%Y-%m-%d %H:%i:%s UTC'))
WHERE termdate IS NOT NULL and termdate !='';

UPDATE hr 
SET hire_date = CASE 
  WHEN hire_date like "%-%" THEN date_format(str_to_date(hire_date,'%m-%d-%Y'),'%Y-%m-%d')
  WHEN hire_date like "%/%" THEN date_format(str_to_date(hire_date,'%m/%d/%Y'),'%Y-%m-%d')
  else NULL
END;  

UPDATE hr 
SET birthdate = CASE 
  WHEN birthdate like '%/%' THEN date_format(str_to_date(birthdate,'%m/%d/%Y'),'%Y-%m-%d')
  WHEN birthdate like '%-%' THEN date_format(str_to_date(birthdate,'%m-%d-%Y'),'%Y-%m-%d')
  ELSE NUll  
END;  

DESCRIBE hr;

ALTER TABLE hr
MODIFY COLUMN birthdate DATE;

ALTER TABLE hr
MODIFY COLUMN hire_date DATE;

ALTER TABLE hr
MODIFY COLUMN termdate DATE;

ALTER TABLE hr
ADD COLUMN age int;
-- create an age column 
UPDATE hr
SET age = timestampdiff(YEAR,birthdate,CURDATE()); 

SELECT count(*) FROM hr WHERE age <18;

-- Data Analysis 

-- 1. Gender breakdown
SELECT gender, count(*) AS COUNT
FROM hr
WHERE age >= 18
GROUP BY gender;

-- 2. Race breakdown 
SELECT race, count(*) AS count
FROM hr
WHERE age >= 18
GROUP BY race
ORDER BY count DESC;

-- 3 Age distribution of employees 
SELECT
  CASE 
	WHEN age >=18 AND age <= 24 THEN '18 to 24'
    WHEN age >=25 AND age <= 34 THEN '25 to 34'
    WHEN age >=35 AND age <= 44 THEN '35 to 44'
    WHEN age >=45 AND age <= 54 THEN '45 to 54'
	ELSE 'Above 54'
   END AS age_group,
   COUNT(*) AS count
FROM hr
GROUP BY age_group
ORDER BY age_group; 

-- 4. Average length of employment before termination
SELECT avg(datediff(termdate,hire_date)/365) as average_length
FROM hr
WHERE termdate != ' ' AND age>=18 AND termdate<=curdate();

-- 5 Which department has the highest turnover rate
SELECT department, 
	total_count, 
    terminated_count,
    terminated_count/total_count AS termination_rate 
FROM
    (SELECT department, 
    count(*) AS total_count,
    SUM(CASE WHEN termdate != '' THEN 1 ELSE 0 END) AS terminated_count
    FROM hr
    WHERE AGE >=18
    GROUP BY department) AS subquery
ORDER BY termination_rate DESC;
    
-- 6 What is the tenure distrbution for each department?
SELECT department, 
       Round(AVG(datediff(termdate,hire_date)/365),2) AS tenure
FROM hr
WHERE termdate !=''
GROUP BY department;
       
    