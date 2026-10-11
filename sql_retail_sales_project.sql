--SQL RETAIL SALES ANALYSIS--

--CREATE TABLE--

CREATE TABLE retail_sales
            (
             transactions_id INT PRIMARY KEY,
			 sale_date DATE,
			 sale_time TIME,
			 customer_id INT,
			 gender	VARCHAR (15),
			 age INT,
			 category VARCHAR (15),
			 quantiy INT,
			 price_per_unit FLOAT,
			 cogs FLOAT,
			 total_sale FLOAT
             );

SELECT * FROM retail_sales;	

--DATA CLEANING--

SELECT COUNT(*) FROM retail_sales;

--Fixing Missing Values--
SELECT * FROM retail_sales
WHERE 
     transactions_id IS NULL
	 OR 	 
	 sale_date IS NULL
	 OR
     sale_time IS NULL
	 OR
	 customer_id IS NULL
	 OR
	 gender	IS NULL
	 OR
	 age IS NULL 
	 OR
	 category IS NULL
	 OR
	 quantiy IS NULL
	 OR
	 price_per_unit IS NULL
	 OR
	 cogs IS NULL
	 OR
	 total_sale IS NULL;	

DELETE FROM retail_sales
WHERE quantiy IS NULL
  AND price_per_unit IS NULL
  AND total_sale IS NULL;

UPDATE retail_sales
SET age = (
    SELECT ROUND (AVG(age))
	FROM retail_sales
	WHERE age IS NOT NULL
)
WHERE age IS NULL;

--Duplicate Values fixing--
SELECT 
     transactions_id,
	 sale_date,
	 sale_time,
	 customer_id,
	 gender,
	 age,
	 category
FROM retail_sales
GROUP BY transactions_id, sale_date, sale_time, customer_id, gender, age, category
HAVING COUNT (*) > 1;

SELECT * 
FROM (
    SELECT*, 
		ROW_NUMBER() OVER (
			PARTITION BY transactions_id, sale_date, sale_time, customer_id, gender, age, category, quantiy, price_per_unit, cogs, total_sale
			ORDER BY ctid
		) AS row_num
	FROM retail_sales
) subquery
WHERE row_num > 1;

--Standardizing Text format--
UPDATE retail_sales
SET
 gender = INITCAP (TRIM(gender)),
 category = INITCAP (TRIM(category));

--Standardizing Date and time format--
SELECT *,
    TO_CHAR(sale_date, 'DD-MM-YYYY') AS formatted_date,
	TO_CHAR(sale_time, 'HH24:MI:SS') AS formatted_time
FROM retail_sales;	

--Outlier Detection and Management--
--Outlier Detection--
SELECT * 
FROM retail_sales
WHERE total_sale > (SELECT AVG(total_sale) + (3 * STDDEV(total_sale)) FROM retail_sales);
--No Outlier Found--

-- =============================================================================
-- GENERATING DEFINITIVE CLEAN DATASET
-- =============================================================================

CREATE TABLE retail_sales_clean_v1 AS
SELECT 
    transactions_id, 
    TO_CHAR(sale_date, 'DD-MM-YYYY') AS formatted_sales_date,
    TO_CHAR(sale_time, 'HH24:MI:SS') AS formatted_sales_time,
    customer_id,
    INITCAP(TRIM(gender)) AS gender,
    COALESCE(
        age, 
        (SELECT ROUND(AVG(age)) FROM retail_sales WHERE age IS NOT NULL)
    ) AS age,
    INITCAP(TRIM(category)) AS category,
    quantiy,
    price_per_unit,
    cogs,
    total_sale
FROM retail_sales
WHERE quantiy IS NOT NULL 
  AND price_per_unit IS NOT NULL 
  AND total_sale IS NOT NULL;
  
SELECT * FROM retail_sales_clean_v1;


--EXPLORATORY DATA ANALYSIS--

--Total Sales--
SELECT COUNT(*) AS total_sales FROM retail_sales_clean_v1;

--Total Customers--
SELECT COUNT(DISTINCT customer_id) AS total_customers FROM retail_sales_clean_v1;

--Number of Categories--
SELECT DISTINCT category FROM retail_sales_clean_v1;
SELECT COUNT(DISTINCT category) AS categories FROM retail_sales_clean_v1;


--Data analysis & Business problems and answers--

--Retrieving all columns of sales made on '05-11-2022'--
SELECT * FROM retail_sales_clean_v1
WHERE formatted_sales_date = '05-11-2022';

--Retrieving all the transactions where the category is 'Clothing' and the quantity sold is more than 4 in the amount of month in 'Nov 22'--
SELECT * FROM retail_sales_clean_v1
WHERE category = 'Clothing'
AND formatted_sales_date LIKE '%-11-2022'
AND quantiy >= 4;

--Calculating total sales for each category--
SELECT category, SUM(total_sale) AS net_sale, COUNT(*) AS total_orders 
FROM retail_sales_clean_v1
GROUP BY 1;

--Average age of customers who purchased items from the Beauty category--
SELECT AVG(age) as average_age
FROM retail_sales_clean_v1
WHERE category = 'Beauty';

--All the transactions where the total_sale is greater than 1000--
SELECT * FROM retail_sales_clean_v1
WHERE total_sale > 1000;

--Total number of transactions(transaction_id) made by each gender in each category--
SELECT gender, category, COUNT (*) AS total_trans
FROM retail_sales_clean_v1
GROUP BY gender, category;

--Calculating avareage sale of each month. (Best selling month in each year)--
SELECT * FROM (	
	WITH monthly_sales AS (
		SELECT
		       EXTRACT(YEAR FROM TO_DATE (formatted_sales_date, 'DD-MM-YYYY')) AS sales_year, 
		       EXTRACT(MONTH FROM TO_DATE (formatted_sales_date, 'DD-MM-YYYY')) AS sales_month,
			   AVG(total_sale) AS avg_sale 
			   
	    FROM retail_sales_clean_v1
	    GROUP BY 1, 2
	) 
	SELECT
	    sales_year,
		sales_month,
		avg_sale,
		RANK() OVER (PARTITION BY sales_year ORDER BY avg_sale DESC) AS sales_rank
	FROM monthly_sales
 ) ranked_sales
 WHERE sales_rank = 1;
	   
--Top 5 customers based on the highest total sales--
SELECT  
   customer_id, 
   SUM(total_sale) AS total_sales
FROM retail_sales_clean_v1
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

--Number of unigue customers who purchased items from each category--
SELECT
   category,
   COUNT (DISTINCT customer_id) AS count_of_unique_customers
FROM retail_sales_clean_v1
GROUP BY category;

--Each shift of number of orders--
SELECT *,
   CASE
      WHEN formatted_sales_time BETWEEN '00:00:00' AND '11:59:59' THEN 'Morning'
	  WHEN formatted_sales_time BETWEEN '12:00:00' AND '16:59:59' THEN 'Afternoon'
	  ELSE 'Evening'
   END AS shift
FROM retail_sales_clean_v1;   



--END OF THE PROJECT--