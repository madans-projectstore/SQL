CREATE DATABASE IF NOT EXISTS WalmartSalesData;
CREATE TABLE sales(
invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
branch	VARCHAR(5) NOT NULL,
city VARCHAR(30) NOT NULL,
customer_type VARCHAR(30) NOT NULL,
gender VARCHAR(10) NOT NULL,
product_line VARCHAR(100) NOT NULL,
unit_price DECIMAL(10, 2) NOT NULL,
quantity INT NOT NULL,
VAT FLOAT(6,4) NOT NULL,
total DECIMAL(12, 4) NOT NULL,
date DATETIME NOT NULL,
time TIME NOT NULL,
payment_method VARCHAR(15) NOT NULL,
cogs DECIMAL(10,2) NOT NULL,
gross_margin_pct FLOAT(11,9),
gross_income DECIMAL(12, 4),
rating FLOAT(2, 1)
);

-- FEATURE ENGINEERING--

SELECT 
	time,
    (CASE
		WHEN time BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN time BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
	END
    ) AS time_of_day
FROM sales;

ALTER TABLE sales ADD COLUMN time_of_day VARCHAR(20);
UPDATE sales
SET time_of_day = (
	CASE
		WHEN time BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN time BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
	END
);
--
ALTER TABLE sales ADD COLUMN day_name VARCHAR(20);
UPDATE sales
SET day_name = DAYNAME(date);

ALTER TABLE sales ADD COLUMN month_name VARCHAR(25);

UPDATE sales
SET month_name = MONTHNAME(date);

-- END--

--  ---Generic Questions--

SELECT DISTINCT city FROM sales;
SELECT distinct city, branch FROM sales;

-- END --

-- --PRODUCT ANALYSIS--
-- How many unique product lines does the data have?
SELECT DISTINCT product_line FROM sales;

-- What is the most common payment method?
SELECT payment_method,
COUNT(payment_method) as cnt
FROM sales
GROUP BY payment_method
ORDER BY cnt DESC;

-- What is the most selling product line?
SELECT product_line,
COUNT(product_line) as cnt_pl
FROM sales GROUP BY product_line
ORDER BY cnt_pl DESC;

-- What is the total revenue by month?
SELECT month_name,
SUM(total) as tr_bymonth
FROM sales GROUP BY month_name
ORDER BY tr_bymonth DESC;

-- What month had the largest COGS?
SELECT month_name,
SUM(cogs) as total_cogs
FROM sales GROUP BY month_name
ORDER BY total_cogs DESC;

-- What product line had the largest revenue?
SELECT product_line,
SUM(total) as total_pl
FROM sales GROUP BY product_line
ORDER BY total_pl DESC;

-- What is the city with the largest revenue?
SELECT city,
SUM(total) as total_rv
FROM sales group by city
ORDER BY total_rv DESC;

-- What product line had the largest VAT?
SELECT product_line,
MAX(VAT) as max_VAT
FROM sales group by product_line
ORDER BY max_VAT DESC;

-- Which branch sold more products than average product sold?
SELECT branch,
SUM(quantity) as qty
FROM sales GROUP BY branch
HAVING SUM(quantity) > (SELECT AVG(quantity) FROM sales);

-- What is the most common product line by gender?
SELECT gender, product_line,
COUNT(gender) as cnt_gen
FROM sales group by gender, product_line
ORDER BY cnt_gen DESC;

-- What is the average rating of each product line?
SELECT product_line,
round(AVG(rating),2) as avg_rat
FROM sales group by product_line
ORDER BY avg_rat DESC;

-- Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales
SELECT AVG(total) as avg_sales
FROM sales;

SELECT product_line,
CASE 
	WHEN AVG(total) > (SELECT AVG(total) FROM sales)THEN "Good"
    ELSE "Bad"
    END as remark
FROM sales GROUP BY product_line;

-- --SALES ANALYSIS--
-- Number of sales made in each time of the day per weekday
SELECT time_of_day, day_name,
COUNT(total) AS no_of_sales
FROM sales GROUP BY time_of_day, day_name
ORDER BY no_of_sales DESC;

-- Which of the customer types brings the most revenue?
SELECT customer_type,
ROUND(SUM(total),2) as Custyp_Rev
FROM sales GROUP BY customer_type
ORDER BY Custyp_Rev DESC;

-- Which city has the largest tax percent/ VAT (Value Added Tax)?
SELECT city,
ROUND(MAX(VAT),0) as largest_vat
FROM sales group by city
ORDER BY largest_vat DESC;

-- Which customer type pays the most in VAT?
SELECT customer_type,
ROUND(MAX(VAT),0) as max_VAT
FROM sales GROUP BY customer_type;

-- --CUSTOMER ANALYSIS--
-- how many unique customer types does the data have?
SELECT DISTINCT customer_type FROM sales;

-- How many unique payment methods does the data have?
SELECT DISTINCT payment_method FROM sales;

-- What is the most common customer type?
SELECT customer_type, COUNT( invoice_id) as no_of_invoices FROM sales
group by customer_type ORDER BY no_of_invoices DESC;

-- Which customer type buys the most?
SELECT customer_type, COUNT(invoice_id) as no_of_invoices FROM sales
group by customer_type ORDER BY no_of_invoices DESC;

-- What is the gender of most of the customers?
SELECT gender, COUNT(invoice_id) as no_of_invoices 
FROM sales group by gender;

-- What is the gender distribution per branch?
SELECT gender, branch, COUNT(invoice_id) as no_of_invoices 
FROM sales group by gender, branch
ORDER BY branch ASC;

-- Which time of the day do customers give most ratings?
SELECT time_of_day, COUNT(rating) AS no_of_ratings
FROM sales GROUP BY time_of_day;

-- Which time of the day do customers give most ratings per branch?
SELECT time_of_day, branch, COUNT(rating) AS no_of_ratings
FROM sales GROUP BY branch, time_of_day
ORDER BY branch ASC, no_of_ratings DESC;

-- Which day of the week has the best avg ratings?
SELECT day_name, AVG(rating) as avg_rating
FROM sales GROUP BY day_name
ORDER BY avg_rating DESC;

-- Which day of the week has the best average ratings per branch?
WITH RankedRatings AS (
	SELECT branch, day_name, AVG(rating) as avg_rating,
    ROW_NUMBER() OVER (PARTITION BY branch ORDER BY avg(rating) DESC) AS rn
    FROM sales GROUP BY branch, day_name
)

SELECT branch, day_name, avg_rating
FROM RankedRatings WHERE rn <= 3
ORDER BY branch ASC, avg_rating DESC;
