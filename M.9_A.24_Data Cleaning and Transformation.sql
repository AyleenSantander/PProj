/*Assignment 24: Data Cleaning and Transformation*/
/*Name Ayleen Santander*/
CREATE DATABASE IF NOT EXISTS LastA24DB;
USE LastA24DB;
SELECT * FROM assign24;

SELECT COUNT(*) AS num_rows
FROM assign24;

SELECT DISTINCT customer_id  FROM assign24;

/*1. Handle Missing Values:
- Fill missing values in the quantity column using the average (mean) quantity (MySQL does not natively support a MEDIAN function).*/
SELECT * FROM assign24;
UPDATE assign24
SET quantity = 
		(SELECT AVG_quantity FROM
			(SELECT ROUND(AVG(quantity)) AS AVG_quantity FROM assign24) AS temp_assign24)
WHERE quantity IS NULL;

/*- Fill missing values in the region column with 'Unknown'.*/
UPDATE assign24
SET region = 'Unknown'
WHERE region IS NULL;

SELECT * FROM assign24;

/*2. Remove Duplicates:
- Identify and remove duplicate records based on customer_id, product_id, and order_date, keeping the earliest record.*/
DELETE FROM assign24
WHERE order_id NOT IN (
    SELECT MIN(order_id)
    FROM (SELECT order_id, customer_id, product_id, order_date FROM assign24) AS temp_assign24
    GROUP BY customer_id, product_id, order_date
);
SELECT * FROM assign24;
/*Check the affected rows,customer_id = 102 was the duplicate values same inf after apply the query it was removing and the total 
values in the tabl decrease at 7 */
SELECT * FROM assign24;
SELECT COUNT(*) AS num_rows FROM assign24;
SELECT DISTINCT * FROM assign24 WHERE customer_id;

/*3. Standardize Formats:
- Convert all values in the order_date column to a consistent date format (YYYY-MM-DD).*/
SELECT * FROM assign24;
UPDATE assign24
SET order_date = 
    CASE
        WHEN order_date LIKE '____/__/__' THEN STR_TO_DATE(order_date, '%Y/%m/%d')  -- modify 2023/01/03
        WHEN order_date LIKE '__/__/____' THEN STR_TO_DATE(order_date, '%d/%m/%Y')  -- modify 01/01/2023
        WHEN order_date LIKE '__-__-____' THEN STR_TO_DATE(order_date, '%d-%m-%Y')  -- modify 02-01-2023
        ELSE order_date
    END;
/*Check the query change them*/
SELECT order_id, order_date FROM assign24;
SELECT * FROM assign24;

/*4. Create Transformed Fields:
- Create or populate the total_sales column as the product of quantity and price_per_unit.*/
SELECT region, SUM(quantity * price_per_unit) AS total_sales
FROM  assign24
GROUP BY region;

/*- Aggregate total sales by region.*/
UPDATE assign24
SET total_sales = quantity * price_per_unit;

SELECT * FROM assign24;

/*5. Generate a Summary Report:
Produce a summary report showing total sales by region*/
SELECT 
    region,
    SUM(total_sales) AS Total_Sales,
    COUNT(*) AS Num_Orders,
    ROUND(AVG(total_sales), 1) AS Avg_Order_Value
FROM assign24
GROUP BY Region
ORDER BY total_sales DESC;