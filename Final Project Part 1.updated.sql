/*Final Project Part 1
Name Ayleen Santander*/
/*Part 1: Database Design*/
CREATE DATABASE IF NOT EXISTS E_CommerceCompanyDB;
USE E_CommerceCompanyDB;

CREATE TABLE customers (
    customerid     INT AUTO_INCREMENT PRIMARY KEY,
    name            VARCHAR(100)  NOT NULL,
    email           VARCHAR(150)  NOT NULL,
    region          VARCHAR(100)  NOT NULL,
    CONSTRAINT uq_customers_email UNIQUE (email)
);
CREATE TABLE products (
    productid      INT AUTO_INCREMENT PRIMARY KEY,
    name            VARCHAR(150)   NOT NULL,
    category        VARCHAR(100)   NOT NULL,
    price           DECIMAL(10,2)  NOT NULL CHECK (price >= 0)
);
/** ADD THE NEW COLUMN SKU*/
ALTER TABLE products ADD COLUMN SKU VARCHAR(255) NOT NULL;
/*Check the new column was added*/
SELECT * FROM products;

CREATE TABLE reviews (
    reviewid       INT AUTO_INCREMENT PRIMARY KEY,
    customerid     INT           NOT NULL,
    productid      INT           NOT NULL,
    rating         INT       NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comments       TEXT,
    review_date    DATE          NOT NULL DEFAULT (CURRENT_DATE),
    CONSTRAINT fk_reviews_customer FOREIGN KEY (customerid) REFERENCES customers(customerid)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_reviews_product FOREIGN KEY (productid) REFERENCES products(productid)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT uq_customer_product_review UNIQUE (customerid, productid)
);
/*I use NOT NULL because the business rule requires every customer to write a comment in order to 
finalize their review, this comment is exactly what triggers the points award. Since the system doesn't 
allow the customer to complete the process without submitting a comment, NULL should never be a valid state 
for this column. Enforcing NOT NULL at the database level guarantees this rule holds even if the application's 
validation fails, has a bug, or a review gets inserted through another route.*/

ALTER TABLE products ADD COLUMN SKU VARCHAR(255) NOT NULL;
INSERT INTO customers (name, email, region) VALUES
('Maria Gonzalez', 'maria.gonzalez@example.com', 'Manitoba'),
('James Whitfield', 'james.whitfield@example.com', 'Ontario'),
('Priya Sharma', 'priya.sharma@example.com', 'British Columbia'),
('Liam O''Connor', 'liam.oconnor@example.com', 'Alberta'),
('Fatima Al-Sayed', 'fatima.alsayed@example.com', 'Quebec'),
('Noah Bergeron', 'noah.bergeron@example.com', 'Manitoba'),
('Chen Wei', 'chen.wei@example.com', 'British Columbia'),
('Sofia Rossi', 'sofia.rossi@example.com', 'Ontario'),
('Ethan Campbell', 'ethan.campbell@example.com', 'Nova Scotia'),
('Aiyana Thunderbird', 'aiyana.thunderbird@example.com', 'Saskatchewan');

SELECT * FROM customers;

INSERT INTO products (name, category, price) VALUES
('Wireless Mouse', 'Electronics', 24.99),
('Standing Desk', 'Furniture', 349.00),
('Noise-Cancelling Headphones', 'Electronics', 199.99),
('Ergonomic Office Chair', 'Furniture', 289.99),
('Mechanical Keyboard', 'Electronics', 89.99),
('LED Desk Lamp', 'Furniture', 34.50),
('27-inch Monitor', 'Electronics', 249.00),
('Laptop Stand', 'Furniture', 45.99),
('USB-C Docking Station', 'Electronics', 129.99),
('Bookshelf Organizer', 'Furniture', 79.00);

/*Populate SKU columns based product_id(note:LPAD= pads string on the left side with a filler until reach the length */
UPDATE products
SET SKU = CONCAT(
	UPPER(LEFT(category, 3)), 
    '-',
    LPAD(productid, 4, '0')
);

SELECT * FROM products;

INSERT INTO reviews (customerid, productid, rating, comments, review_date) VALUES
(1, 1, 5, 'Works great, very responsive.', '2026-05-12'),
(2, 2, 4, 'Sturdy but assembly took a while.', '2026-06-01'),
(3, 3, 5, 'Excellent sound quality.', '2026-06-20'),
(1, 3, 4, 'Good value for the price.', '2026-07-02'),
(4, 4, 5, 'Very comfortable for long work hours.', '2026-05-18'),
(5, 5, 4, 'Great tactile feedback, a bit loud.', '2026-05-25'),
(6, 6, 3, 'Decent brightness but flimsy base.', '2026-06-10'),
(7, 7, 5, 'Crisp display, colors are accurate.', '2026-06-15'),
(8, 8, 4, 'Simple and effective for the price.', '2026-07-05'),
(9, 9, 5, 'Handles multiple monitors flawlessly.', '2026-07-10');

SELECT * FROM reviews;

ALTER TABLE Reviews RENAME COLUMN Review_Date TO Full_Date;

/*Create the Dim Date  table*/
/*rebuild dim_date*/
TRUNCATE TABLE OrdersFact;
DROP TABLE IF EXISTS Dim_Date;
DROP TABLE IF EXISTS OrdersFact;
CREATE TABLE Dim_Date (
    DateID     INT PRIMARY KEY,
    Full_Date  DATE NOT NULL UNIQUE,
    Year       INT NOT NULL,
    Quarter    INT NOT NULL,
    Month      INT NOT NULL,
    MonthName  VARCHAR(10) NOT NULL,
    DayOfWeek  VARCHAR(10) NOT NULL
) ENGINE=InnoDB;

INSERT INTO Dim_Date (DateID, Full_Date, Year, Quarter, Month, MonthName, DayOfWeek)
SELECT
    CAST(DATE_FORMAT(d, '%Y%m%d') AS UNSIGNED),
    d, YEAR(d), QUARTER(d), MONTH(d), MONTHNAME(d), DAYNAME(d)
FROM (
    SELECT (SELECT MIN(Full_Date) FROM Reviews) + INTERVAL (a.a + b.a * 10 + c.a * 100) DAY AS d
    FROM
        (SELECT 0 a UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4
         UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) a
        CROSS JOIN
        (SELECT 0 a UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4
         UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) b
        CROSS JOIN
        (SELECT 0 a UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4) c
) dates
WHERE d <= (SELECT MAX(Full_Date) FROM Reviews);
SELECT * FROM Dim_Date;

/*Create a index to find query fasted*/
CREATE INDEX idx_products_category ON products(category);
CREATE INDEX idx_reviews_rating    ON reviews(rating);
CREATE INDEX idx_reviews_date      ON reviews(review_date);

SHOW INDEX FROM customers; SHOW INDEX FROM products; SHOW INDEX FROM reviews;

SELECT * FROM customers; SELECT * FROM products; SELECT * FROM reviews;

/*Create  query retrieve the customer name,comments and Full_date with indexes*/
CREATE INDEX idx_reviews_date ON reviews(Full_Date);
SELECT c.customerid, c.name, r.reviewid, r.comments, r.Full_Date
FROM customers c
JOIN reviews r ON c.customerid = r.customerid
WHERE r.Full_Date > '2026-06-01' AND '2026-06-30';

/*Create query retrieve products_category, customer name and region for all category furniture*/
SELECT * FROM customers; SELECT * FROM products; SELECT * FROM reviews;
CREATE INDEX idx_products_category ON products(category);

SELECT r.customerid, p.productid, p.name, p.category
FROM products p 
JOIN reviews r ON p.productid = r.productid
WHERE p.category = 'Furniture';

/*Create query retrieve the rating > 3 for each customer and include region */
SELECT * FROM customers; SELECT * FROM products; SELECT * FROM reviews; SELECT * FROM OrdersFact;

CREATE INDEX idx_reviews_rating ON reviews(rating);

SELECT c.customerid, c.name, c.region, r.rating
FROM customers c
JOIN reviews r ON r.reviewid = c.customerid
WHERE rating > 2;

/*Part 2: Data Integration
Stage first. Create one staging table per source with every column typed as text, 
then validate on the way into your final tables.*/
CREATE TABLE customer_survey (
    response_id VARCHAR(20) PRIMARY KEY,
    submitted_on VARCHAR(20),
    respondent_name VARCHAR(255) NOT NULL,
    respondent_email VARCHAR(100) NOT NULL,
    product_label VARCHAR(255),
    sku VARCHAR(20),
    rating_1_5 TINYINT,
    open_comment TEXT,
    channel VARCHAR(50)
);
SELECT * FROM customer_survey;
/*Check the duplicates*/
SELECT COUNT(*) AS num_rows FROM customer_survey;
SELECT DISTINCT sku FROM customer_survey;
/*Best options check duplicates by occurrences*/
/*This first option only provide 3 respondent_email contains the occurrences */
SELECT respondent_email, product_label, submitted_on, COUNT(*) AS occurrences
FROM customer_survey
GROUP BY respondent_email, product_label, submitted_on
HAVING COUNT(*) > 1;
/*and apply this seconde code to be sure and this ones shows me the entire information
and detailed of each duplicate information*/
SELECT c.*
FROM customer_survey c
JOIN (
    SELECT respondent_email, product_label, submitted_on
    FROM customer_survey
    GROUP BY respondent_email, product_label, submitted_on
    HAVING COUNT(*) > 1
) dup
ON c.respondent_email = dup.respondent_email
   AND c.product_label = dup.product_label
   AND c.submitted_on = dup.submitted_on
ORDER BY c.respondent_email, c.submitted_on;

/*step 2: Create table for JSON  after change format in python*/
CREATE TABLE web_feedback_from_json (
    submission_id text,
    received_at   text,
    customer_name text,
    customer_email text,
    verified      text,
    product_sku   text,
    product_title text,
    score         text,
    message       TEXT,
    tags          text
);
SELECT * FROM web_feedback_from_json ;
/*Check the duplicates*/
SELECT COUNT(*) AS num_rows FROM web_feedback_from_json;
/*Whom is duplicated*/
SELECT customer_name, submission_id, COUNT(*) AS num_submissions
FROM web_feedback_from_json
GROUP BY customer_name, submission_id;

SELECT DISTINCT customer_name, submission_id FROM web_feedback_from_json;
SELECT COUNT(*) AS submission_id FROM web_feedback_from_json;

/*Step 3: Create a XML table*/
CREATE TABLE external_reviews_native (
    id         VARCHAR(20),
    postedOn   VARCHAR(20),
    displayName VARCHAR(100),
    email      VARCHAR(255),
    country    VARCHAR(10),
    item       VARCHAR(255),
    score      VARCHAR(10),
    body       TEXT,
    helpfulVotes INT
);

/*Show variables inside*/
SHOW VARIABLES LIKE 'secure_file_priv';
LOAD XML INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/external_reviews.xml'
INTO TABLE external_reviews_native
ROWS IDENTIFIED BY '<review>';

/*check the load xml file*/
SELECT * FROM external_reviews_native LIMIT 10;

/*Adding missing columns*/
ALTER TABLE external_reviews_native
    ADD COLUMN sku VARCHAR(30),
    ADD COLUMN score_scale VARCHAR(10);
    
/*check the load xml file*/
SELECT * FROM external_reviews_native LIMIT 10;

/*Check the duplicates*/
SELECT COUNT(*) AS num_rows FROM external_reviews_native;
/*duplicate rows, the query shows no duplicate rows*/
SELECT displayName, sku, COUNT(*) AS num_rows
FROM external_reviews_native
GROUP BY displayName, sku;

SELECT DISTINCT displayName, sku FROM external_reviews_native;
SELECT COUNT(*) AS submission_id FROM external_reviews_native;

/*Create a external reviews raw*/    
CREATE TABLE external_reviews_raw (
    xml_data LONGTEXT
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/external_reviews.xml'
INTO TABLE external_reviews_raw
FIELDS TERMINATED BY '\x01'
LINES TERMINATED BY '\x02'
(xml_data);
/*Check if the landed was correctly*/
SELECT LEFT(xml_data, 200) FROM external_reviews_raw;
/*Create the procedure to refer raw table*/
SET SQL_SAFE_UPDATES = 0;
DELIMITER //

CREATE PROCEDURE populate_reviews()
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE v_id VARCHAR(20);
    DECLARE cur CURSOR FOR SELECT id FROM external_reviews_native;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    OPEN cur;
    read_loop: LOOP
        FETCH cur INTO v_id;
        IF done THEN
            LEAVE read_loop;
        END IF;

        SET @sql = CONCAT(
            'UPDATE external_reviews_native n JOIN external_reviews_raw r ON 1=1 ',
            'SET n.displayName = ExtractValue(r.xml_data, ''//review[@id="', v_id, '"]/reviewer/displayName''), ',
            'n.email = ExtractValue(r.xml_data, ''//review[@id="', v_id, '"]/reviewer/email''), ',
            'n.country = ExtractValue(r.xml_data, ''//review[@id="', v_id, '"]/reviewer/country''), ',
            'n.sku = ExtractValue(r.xml_data, ''//review[@id="', v_id, '"]/item/@sku''), ',
            'n.score_scale = ExtractValue(r.xml_data, ''//review[@id="', v_id, '"]/score/@outOf'') ',
            'WHERE n.id = ''', v_id, ''''
        );

        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END LOOP;
    CLOSE cur;
END //

DELIMITER ;
SET SQL_SAFE_UPDATES = 1;
CALL populate_reviews();
SHOW PROCEDURE STATUS LIKE 'populate_reviews';

/*Check the result*/
SELECT * FROM external_reviews_native LIMIT 10;

/*Retrieve all tables*/
SELECT * FROM Customer_survey; SELECT * FROM external_reviews_native; SELECT * FROM web_feedback_from_json;

/*5.Clean with UPDATE statements, each one separate and commented. 
At minimum, handle: 
/*inconsistent case and whitespace email web_feedback and external_reviews add 'unknown'*/
SET SQL_SAFE_UPDATES = 0;
UPDATE web_feedback_from_json
SET customer_email = 'unknown'
WHERE customer_email = '' OR customer_email IS NULL;

UPDATE external_reviews_native
SET email = 'unknown'
WHERE email = '' OR email IS NULL;
SET SQL_SAFE_UPDATES = 1;
/*Retrieve all changes*/
SELECT * FROM Customer_survey; SELECT * FROM external_reviews_native; SELECT * FROM web_feedback_from_json;
/*set consistency respondent_name into customer_survey */
SET SQL_SAFE_UPDATES = 0;
UPDATE Customer_survey
SET respondent_name = CONCAT(
    UPPER(SUBSTRING(SUBSTRING_INDEX(respondent_name, ' ', 1), 1, 1)),
    LOWER(SUBSTRING(SUBSTRING_INDEX(respondent_name, ' ', 1), 2)),
    ' ',
    UPPER(SUBSTRING(SUBSTRING_INDEX(respondent_name, ' ', -1), 1, 1)),
    LOWER(SUBSTRING(SUBSTRING_INDEX(respondent_name, ' ', -1), 2))
)
WHERE respondent_name LIKE '% %';

SET SQL_SAFE_UPDATES = 1;
/*Verify the update*/
SELECT * FROM Customer_survey;
   
/*Check on rows counts*/
SELECT COUNT(*) FROM Customer_survey;
SELECT COUNT(*) FROM external_reviews_native;
SELECT COUNT(*) FROM web_feedback_from_json;
/*Fix date formats a column containing two date formats*/
/*Retrieve all changes*/
SELECT * FROM Customer_survey; SELECT * FROM external_reviews_native; SELECT * FROM web_feedback_from_json;
/*check any row where day firsr vs month */
SELECT submitted_on
FROM customer_survey
WHERE submitted_on LIKE '__/__/____'
ORDER BY submitted_on;

/*check the update*/
SELECT submitted_on FROM customer_survey LIMIT 20;
/*Update the wrong dates formats*/
SET SQL_SAFE_UPDATES = 0;
SELECT * FROM customer_survey;
UPDATE customer_survey
SET submitted_on = 
    CASE
        WHEN submitted_on LIKE '____/__/__' THEN STR_TO_DATE(submitted_on, '%Y-%m-%d') 
        WHEN submitted_on LIKE '__/__/____' THEN STR_TO_DATE(submitted_on, '%m/%d/%Y')  
        WHEN submitted_on LIKE '__-__-____' THEN STR_TO_DATE(submitted_on, '%d-%m-%Y')  
        ELSE submitted_on
    END;
/*check the query*/
SELECT submitted_on FROM customer_survey LIMIT 20;

/*ratings outside the valid range*/
/*check first the values*/
SELECT rating_1_5, COUNT(*) AS occurrences
FROM customer_survey
GROUP BY rating_1_5
ORDER BY rating_1_5;
/*isolete the problem*/
SELECT *
FROM customer_survey
WHERE rating_1_5 NOT BETWEEN 1 AND 5
   OR rating_1_5 IS NULL;
/*Set out of range values to null*/
SET SQL_SAFE_UPDATES =0;
UPDATE customer_survey
SET rating_1_5 = NULL
WHERE rating_1_5 NOT BETWEEN 1 AND 5;
SET SQL_SAFE_UPDATES =1;
/*Call/check the result*/
SELECT rating_1_5, COUNT(*) AS occurrences
FROM customer_survey
WHERE rating_1_5 IS NOT NULL
GROUP BY rating_1_5
ORDER BY rating_1_5;
/*check the nulls rows*/
SELECT * FROM customer_survey WHERE rating_1_5 IS NULL;

/*a rating scale that differs from the other feeds*/
/*step 1:Check the survey's declared scale*/
SELECT rating_1_5 FROM customer_survey ORDER BY rating_1_5;
/*Delete the null*/
SET SQL_SAFE_UPDATES = 0;
DELETE FROM customer_survey
WHERE rating_1_5 IS NULL;
SET SQL_SAFE_UPDATES = 1;
/*check the rating*/
SELECT DISTINCT rating_1_5 FROM customer_survey ORDER BY rating_1_5;

/*step 2:Check the XML source's actual scale attribute*/
SELECT DISTINCT score_scale FROM external_reviews_native;
/*Apply normalization add new column score_normalized*/
ALTER TABLE external_reviews_native ADD COLUMN score_normalized DECIMAL(3,1);

SET SQL_SAFE_UPDATES = 0;
UPDATE external_reviews_native
SET score_normalized = (score / score_scale) * 5;
/*Verify the output*/
SELECT score, score_scale, score_normalized FROM external_reviews_native LIMIT 10;
/*Duplicate submissions.The duplicates do not share a record ID, so you will need to define a business key to find them.*/
/*Find duplicated*/
SELECT respondent_email, product_label, rating_1_5, open_comment, COUNT(*) AS occurrences
FROM customer_survey
GROUP BY respondent_email, product_label, rating_1_5, open_comment
HAVING COUNT(*) > 1;
/*confirm if those records are genuine duplicate submission*/
SELECT c.*
FROM customer_survey c
JOIN (
    SELECT respondent_email, product_label, rating_1_5, open_comment
    FROM customer_survey
    GROUP BY respondent_email, product_label, rating_1_5, open_comment
    HAVING COUNT(*) > 1
) dup
  ON c.respondent_email = dup.respondent_email
 AND c.product_label = dup.product_label
 AND c.rating_1_5 = dup.rating_1_5
 AND c.open_comment = dup.open_comment
ORDER BY c.respondent_email;
/*Delete the duplicates and keep the earlist one*/
SET SQL_SAFE_UPDATES =0;
DELETE c1 FROM customer_survey c1
JOIN customer_survey c2
  ON c1.respondent_email = c2.respondent_email
 AND c1.product_label = c2.product_label
 AND c1.rating_1_5 = c2.rating_1_5
 AND c1.open_comment = c2.open_comment
 AND c1.response_id > c2.response_id;
 SET SQL_SAFE_UPDATES =1;
/*Verify the clean*/
SELECT respondent_email, product_label, rating_1_5, open_comment, COUNT(*) AS occurrences
FROM customer_survey
GROUP BY respondent_email, product_label, rating_1_5, open_comment
HAVING COUNT(*) > 1;
/*6. Log anything you reject or null out, with a reason, in a reject table. Deleting silently makes your row counts impossible to reconcile.*/
CREATE TABLE dim_customer (
    customer_id   INT AUTO_INCREMENT PRIMARY KEY,
    email         VARCHAR(255) NOT NULL UNIQUE,
    customer_name VARCHAR(255)
);
DROP TABLE IF EXISTS fact_review;
CREATE TABLE fact_review (
    review_id         INT AUTO_INCREMENT PRIMARY KEY,
    source_system     VARCHAR(30)  NOT NULL,
    source_id         VARCHAR(50)  NOT NULL,
    customer_id       INT,
    product_sku       VARCHAR(20),
    product_title     VARCHAR(255),
    score_raw         DECIMAL(4,1),
    score_normalized  DECIMAL(3,1),
    review_date       DATETIME,
    review_text       TEXT,
    channel           VARCHAR(50),
    country           VARCHAR(5),
    verified          BOOLEAN,
    helpful_votes     INT,
    CONSTRAINT fk_fact_review_customer
        FOREIGN KEY (customer_id) REFERENCES dim_customer(customer_id),
    CONSTRAINT uq_source_row UNIQUE (source_system, source_id)
);

/*Create Reject_log*/
CREATE TABLE reject_log (
    reject_id       INT AUTO_INCREMENT PRIMARY KEY,
    source_system   VARCHAR(30)  NOT NULL,   
    source_id       VARCHAR(50)  NOT NULL, 
    column_name     VARCHAR(50)  NOT NULL,  
    original_value  VARCHAR(255),          
    reject_reason   VARCHAR(255) NOT NULL,
    logged_at       DATETIME DEFAULT CURRENT_TIMESTAMP
);
/*Retrieve all changes*/
SELECT * FROM Customer_survey; SELECT * FROM external_reviews_native; SELECT * FROM web_feedback_from_json;
/*Create the Fact_reviews combine all tables in ones*/
-- Customer_survey = fact_review
INSERT INTO fact_review
    (source_system, source_id, customer_id, product_sku, product_title,
     score_raw, score_normalized, review_date, review_text, channel)
SELECT
	s.review_id, 'customer_survey', s.response_id, c.customer_id, s.sku, s.product_label,
    s.rating_1_5, s.rating_1_5, s.submitted_on, s.open_comment, s.channel
FROM Customer_survey s
LEFT JOIN dim_customer c ON c.email = LOWER(TRIM(s.respondent_email))
ON DUPLICATE KEY UPDATE customer_id = c.customer_id;
-- external_reviews_native = fact_review
INSERT INTO fact_review
    (source_system, source_id, customer_id, product_sku, product_title,
     score_raw, score_normalized, review_date, review_text, channel, country, helpful_votes)
SELECT
    'external_reviews', e.id, c.customer_id, e.sku, e.item,
    e.score, e.score_normalized, e.postedOn, e.body, 'external', e.country, e.helpfulVotes
FROM external_reviews_native e
LEFT JOIN dim_customer c ON c.email = LOWER(TRIM(e.email))
ON DUPLICATE KEY UPDATE customer_id = c.customer_id;
-- web_feedback_from_json = fact_review
INSERT INTO fact_review
    (source_system, source_id, customer_id, product_sku, product_title,
     score_raw, review_date, review_text, verified)
SELECT
    'web_feedback', w.submission_id, c.customer_id, w.product_sku, w.product_title,
    w.score,
    STR_TO_DATE(REPLACE(REPLACE(w.received_at, 'T', ' '), 'Z', ''), '%Y-%m-%d %H:%i:%s'),
    w.message,
    CASE WHEN w.verified = 'True' THEN 1 ELSE 0 END
FROM web_feedback_from_json w
LEFT JOIN dim_customer c ON c.email = LOWER(TRIM(w.customer_email))
ON DUPLICATE KEY UPDATE customer_id = c.customer_id;
/* Verify: row counts per source*/
SELECT source_system, COUNT(*) AS promoted_rows
FROM fact_review
GROUP BY source_system;

/*Check the tables */
SHOW TABLES LIKE 'fact_review';
SHOW TABLES LIKE 'dim_customer';
SHOW TABLES LIKE 'reject_log';
/*7.Promote staging into your final tables. Reviews with no matching customer must still load.*/
CREATE OR REPLACE VIEW vw_all_reviews_combined AS
SELECT response_id AS source_id, 'customer_survey' AS source_system FROM Customer_survey
UNION ALL
SELECT id, 'external_reviews' FROM external_reviews_native
UNION ALL
SELECT submission_id, 'web_feedback' FROM web_feedback_from_json;
SHOW TABLES LIKE 'vw_all_reviews_combined';
/*check the new table*/
SELECT * FROM vw_all_reviews_combined;
SELECT COUNT(*) FROM vw_all_reviews_combined;
/*confirm all three sources are present===*/
SELECT source_system, COUNT(*) AS row_count
FROM vw_all_reviews_combined
GROUP BY source_system;

/*Part 3: Queries, Optimization and Testing*/
SELECT * FROM Customers; SELECT * FROM reviews; SELECT * FROM products;
/*Top products by rating and sales. Ranking on raw AVG(rating) puts a two-review product on top; 
address this with a review threshold or a weighted score.*/
SELECT p.productid, p.name, p.category, COUNT(r.reviewid)  AS review_count,
       AVG(r.rating) AS avg_rating, SUM(p.price) AS sales_proxy
FROM Products p
JOIN Reviews r ON r.productid = p.productid
GROUP BY p.productid, p.name, p.category
HAVING COUNT(r.reviewid) >= 1
ORDER BY avg_rating DESC, review_count DESC
LIMIT 20;

/*Recurring issues, grouped into categories. Store the keyword mapping as data in a table, not as a hard-coded CASE chain.*/
/*Create a keywords mapping table*/
CREATE TABLE issue_keyword_map (
    keyword_id   INT AUTO_INCREMENT PRIMARY KEY,
    keyword      VARCHAR(100) NOT NULL,
    category     VARCHAR(100) NOT NULL
);
/*Populate the new table with keywords and category*/
TRUNCATE TABLE issue_keyword_map;

INSERT INTO issue_keyword_map (keyword, category) VALUES
('responsive',   'Performance - Positive'),
('effective',    'Performance - Positive'),
('sturdy',       'Build Quality - Positive'),
('flimsy',       'Build Quality Issue'),
('assembly',     'Assembly/Setup Issue'),
('sound quality','Audio Quality - Positive'),
('tactile',      'Feel/Tactile - Positive'),
('loud',         'Noise Issue'),
('brightness',   'Display Issue'),
('crisp',        'Display Quality - Positive'),
('colors',       'Display Quality - Positive'),
('accurate',     'Display Quality - Positive'),
('comfortable',  'Comfort - Positive'),
('value',        'Value/Price - Positive'),
('price',        'Value/Price - Positive');

INSERT INTO issue_keyword_map (keyword, category) VALUES
('flawlessly', 'Performance - Positive');
/*Match reviews to categories and comments reviews*/
SELECT r.reviewid, r.comments, k.category
FROM Reviews r
LEFT JOIN issue_keyword_map k
    ON r.comments LIKE CONCAT('%', k.keyword, '%')
ORDER BY r.reviewid;
/*Retrieve count each category and numbers positive, issues and more*/
SELECT k.category, COUNT(DISTINCT r.reviewid) AS mention_count
FROM Reviews r
JOIN issue_keyword_map k
    ON r.comments LIKE CONCAT('%', k.keyword, '%')
GROUP BY k.category
ORDER BY mention_count DESC;
/*Rating trend by month, positive/negative split, keyword frequency, and customer engagement by region.*/
/*Rating trend by month*/
SELECT DATE_FORMAT(Full_Date, '%Y-%m') AS review_month,
       COUNT(*) AS review_count,
       ROUND(AVG(rating), 2) AS avg_rating
FROM Reviews
GROUP BY DATE_FORMAT(Full_Date, '%Y-%m')
ORDER BY review_month;
/*positive/negative split*/
SELECT
    CASE
        WHEN rating >= 4 THEN 'Positive'
        WHEN rating = 3  THEN 'Neutral'
        ELSE 'Negative'
    END AS sentiment,
    COUNT(*) AS review_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Reviews), 1) AS pct_of_total
FROM Reviews
GROUP BY sentiment
ORDER BY FIELD(sentiment, 'Positive', 'Neutral', 'Negative');
/*keyword frequency,*/
SELECT k.category, k.keyword, COUNT(*) AS mention_count
FROM Reviews r
JOIN issue_keyword_map k
    ON r.comments LIKE CONCAT('%', k.keyword, '%')
GROUP BY k.category, k.keyword
ORDER BY mention_count DESC;
/*Customer engagement by region*/
SELECT c.region,
       COUNT(r.reviewid) AS total_reviews,
       COUNT(DISTINCT r.customerid) AS distinct_reviewers,
       ROUND(AVG(r.rating), 2) AS avg_rating
FROM Customers c
LEFT JOIN Reviews r ON r.customerid = c.customerid
GROUP BY c.region
ORDER BY total_reviews DESC;
/*A comparison of the three sources. They will not agree — quantify by how much.*/
SELECT
    sku,
    COALESCE(CAST(survey_avg AS CHAR), 'No Data') AS survey_avg,
    COALESCE(CAST(external_avg AS CHAR), 'No Data') AS external_avg,
    COALESCE(CAST(web_avg AS CHAR), 'No Data') AS web_avg
FROM (
    SELECT
        sku,
        ROUND(AVG(CASE WHEN source = 'survey' THEN score_0to5 END), 2) AS survey_avg,
        ROUND(AVG(CASE WHEN source = 'external' THEN score_0to5 END), 2) AS external_avg,
        ROUND(AVG(CASE WHEN source = 'web' THEN score_0to5 END), 2) AS web_avg
    FROM (
        SELECT sku, 'survey' AS source, rating_1_5 AS score_0to5
        FROM Customer_survey
        WHERE rating_1_5 IS NOT NULL
        UNION ALL
        SELECT sku, 'external', score_normalized
        FROM external_reviews_native
        WHERE score_normalized IS NOT NULL
        UNION ALL
        SELECT product_sku, 'web', score / 2.0
        FROM web_feedback_from_json
        WHERE score IS NOT NULL
    ) combined
    GROUP BY sku
    HAVING COUNT(DISTINCT source) > 1
) averages
ORDER BY sku;
/*Create two views: top-rated products, and flagged reviews. Define "flagged" yourself and justify the threshold.*/
/* top-rated products*/
DROP VIEW IF EXISTS vw_top_rated_products;
CREATE VIEW vw_top_rated_products AS
SELECT
    p.productid, p.name, p.category, COUNT(r.reviewid) AS review_count,
    ROUND(AVG(r.rating), 2) AS avg_rating
FROM Products p
JOIN Reviews r ON r.productid = p.productid
GROUP BY p.productid, p.name, p.category
HAVING COUNT(r.reviewid) >= 1
ORDER BY avg_rating DESC, review_count DESC;
/*flagged reviews*/
CREATE VIEW vw_flagged_reviews AS
    SELECT DISTINCT
        r.reviewid,
        r.customerid,
        r.productid,
        r.rating,
        r.comments,
        r.Full_Date,
        CASE
            WHEN r.rating <= 2 THEN 'Low Rating'
            ELSE 'Negative Keyword'
        END AS flag_reason
    FROM
        Reviews r
            LEFT JOIN
        issue_keyword_map k ON r.comments LIKE CONCAT('%', k.keyword, '%')
            AND k.category LIKE '%Issue%'
    WHERE
        r.rating <= 2 OR k.category IS NOT NULL;
/*Call both views */
SELECT * FROM vw_top_rated_products; SELECT * FROM vw_flagged_reviews;
/*4.Add indexes only where a query you wrote needs one, and name the query each serves. 
Create them after the bulk load and explain why the order matters. Run EXPLAIN before and after, and paste both into your report.*/
/*Explanation before queries*/
EXPLAIN SELECT p.productid, p.name, p.category, COUNT(r.reviewid) AS review_count, AVG(r.rating) AS avg_rating
FROM Products p
JOIN Reviews r ON r.productid = p.productid
GROUP BY p.productid, p.name, p.category;

EXPLAIN SELECT * FROM Reviews WHERE rating <= 2;

EXPLAIN SELECT c.region, COUNT(r.reviewid), AVG(r.rating)
FROM Customers c
LEFT JOIN Reviews r ON r.customerid = c.customerid
GROUP BY c.region;

EXPLAIN SELECT DATE_FORMAT(Full_Date, '%Y-%m') AS review_month, COUNT(*), AVG(rating)
FROM Reviews
GROUP BY DATE_FORMAT(Full_Date, '%Y-%m');
/*Create indexes*/
/*JOIN in vw_top_rated_products, and any Reviews=Products join*/
CREATE INDEX idx_reviews_productid ON Reviews(productid);
/*WHERE rating <= 2 filter in vw_flagged_reviews*/
CREATE INDEX idx_reviews_rating ON Reviews(rating);
/*GROUP BY region in customer engagement query*/
CREATE INDEX idx_customers_region ON Customers(region);
/*GROUP BY month in rating trend query*/
CREATE INDEX idx_reviews_fulldate ON Reviews(Full_Date);
SHOW INDEX FROM Reviews;
/*Explanation after indexes*/
EXPLAIN SELECT p.productid, p.name, p.category, COUNT(r.reviewid) AS review_count, AVG(r.rating) AS avg_rating
FROM Products p
JOIN Reviews r ON r.productid = p.productid
GROUP BY p.productid, p.name, p.category;

EXPLAIN SELECT * FROM Reviews WHERE rating <= 2;

EXPLAIN SELECT c.region, COUNT(r.reviewid), AVG(r.rating)
FROM Customers c
LEFT JOIN Reviews r ON r.customerid = c.customerid
GROUP BY c.region;

EXPLAIN SELECT DATE_FORMAT(Full_Date, '%Y-%m') AS review_month, COUNT(*), AVG(rating)
FROM Reviews
GROUP BY DATE_FORMAT(Full_Date, '%Y-%m');

/*5. Write validation queries that return a clear pass or fail: rows staged equals rows loaded plus rejected; 
no record loaded twice; all ratings in range; no orphaned foreign keys; all dates plausible; 
the combined view row count matches the review table; aggregate totals reconcile to the underlying rows.*/
/*rows staged equals rows loaded plus rejected*/
SELECT
    (SELECT COUNT(*) FROM Customer_survey) + (SELECT COUNT(*) FROM external_reviews_native) + (SELECT COUNT(*) FROM web_feedback_from_json) AS total_staged,
    (SELECT COUNT(*) FROM fact_review) AS total_loaded, (SELECT COUNT(*) FROM reject_log) AS total_rejected,
    CASE
        WHEN (SELECT COUNT(*) FROM Customer_survey)
           + (SELECT COUNT(*) FROM external_reviews_native)
           + (SELECT COUNT(*) FROM web_feedback_from_json)
           = (SELECT COUNT(*) FROM fact_review)
        THEN 'PASS'
        ELSE 'FAIL'
    END AS reconciliation_check;
/*no record loaded twice*/
SELECT 'Check 2: No Duplicates' AS check_name,
    COUNT(*) AS duplicate_groups,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS result
FROM (
    SELECT source_system, source_id
    FROM fact_review
    GROUP BY source_system, source_id
    HAVING COUNT(*) > 1
) dupes;
/*all ratings in range*/
SELECT 'Check 3: Ratings In Range' AS check_name,
    COUNT(*) AS out_of_range_count,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS result
FROM fact_review
WHERE score_normalized IS NOT NULL
  AND score_normalized NOT BETWEEN 0 AND 5;
/*no orphaned foreign keys*/
SELECT 'Check 4: No Orphaned FKs' AS check_name,    COUNT(*) AS orphan_count,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS result
FROM fact_review f
LEFT JOIN dim_customer c ON f.customer_id = c.customer_id
WHERE f.customer_id IS NOT NULL
  AND c.customer_id IS NULL;
/* all dates plausible;*/
SELECT 
    'Check 5: Plausible Dates' AS check_name,
    COUNT(*) AS implausible_count,
    CASE
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE 'FAIL'
    END AS result
FROM
    fact_review
WHERE
    review_date IS NOT NULL
        AND (review_date > NOW()
        OR review_date < '2020-01-01');
/*the combined view row count matches the review table*/
SELECT 'Check 6: Combined View Matches fact_review' AS check_name,
    (SELECT COUNT(*) FROM vw_all_reviews_combined) AS combined_view_count,
    (SELECT COUNT(*) FROM fact_review) AS fact_review_count,
    CASE
        WHEN (SELECT COUNT(*) FROM vw_all_reviews_combined) = (SELECT COUNT(*) FROM fact_review)
        THEN 'PASS' ELSE 'FAIL'
    END AS result;
/*aggregate totals reconcile to the underlying rows.*/
SELECT 'Check 7: Aggregate Reconciliation' AS check_name,
    fr_summary.source_system,
    fr_summary.reported_avg,
    recompute.actual_avg,
    CASE WHEN fr_summary.reported_avg = recompute.actual_avg THEN 'PASS' ELSE 'FAIL' END AS result
FROM (
    SELECT source_system, ROUND(AVG(score_normalized), 4) AS reported_avg
    FROM fact_review
    WHERE score_normalized IS NOT NULL
    GROUP BY source_system
) fr_summary
JOIN (
    SELECT source_system, ROUND(AVG(score_normalized), 4) AS actual_avg
    FROM fact_review
    WHERE score_normalized IS NOT NULL
    GROUP BY source_system
) recompute ON recompute.source_system = fr_summary.source_system;
/*Optional, for bonus marks: a stored procedure that promotes staging to final tables inside a transaction with an error handler,
or a stored function that centralizes a definition such as a rating band.*/
-- /*Create for each table final table*/
-- DROP TABLE customers_final;
-- DRop table reviews_final;
-- CREATE TABLE customers_final (
--     customer_id INT PRIMARY KEY,
--     first_name  VARCHAR(100),
--     last_name   VARCHAR(100),
--     email       VARCHAR(150),
--     signup_date DATE
-- );

-- CREATE TABLE reviews_final (
--     review_id    INT PRIMARY KEY,
--     customer_id  INT NULL,
--     product_id   INT,
--     rating       INT,
--     review_text  TEXT,
--     review_date  DATE,
--     FOREIGN KEY (customer_id) REFERENCES customers_final(customer_id)
-- );
-- /*Create the final procedure*/
-- DROP FUNCTION IF EXISTS fn_rating_band;
-- DROP PROCEDURE IF EXISTS sp_promote_staging_to_final;
-- DROP VIEW IF EXISTS vw_all_feedback_combined;
-- DROP TABLE IF EXISTS some_table;
-- DELIMITER //

-- CREATE PROCEDURE sp_promote_staging_to_final()
-- BEGIN
--     START TRANSACTION;
--     INSERT INTO customers_final (customer_id, first_name, last_name, email, signup_date)
--     SELECT DISTINCT
--         CAST(customer_id AS UNSIGNED), first_name, last_name, email,
--         STR_TO_DATE(signup_date, '%Y-%m-%d')
--     FROM customers_staging
--     WHERE customer_id REGEXP '^[0-9]+$';
--     INSERT INTO reviews_final (review_id, customer_id, product_id, rating, review_text, review_date)
--     SELECT
--         CAST(r.review_id AS UNSIGNED),
--         CASE WHEN c.customer_id IS NOT NULL THEN CAST(r.customer_id AS UNSIGNED) ELSE NULL END,
--         CAST(r.product_id AS UNSIGNED),
--         CAST(r.rating AS UNSIGNED),
--         r.review_text,
--         STR_TO_DATE(r.review_date, '%Y-%m-%d')
--     FROM reviews_staging r
--     LEFT JOIN customers_final c
--         ON r.customer_id = c.customer_id
--     WHERE r.review_id REGEXP '^[0-9]+$';

--     COMMIT;
-- END//

-- DELIMITER ;
-- /*Call procedure*/
-- CALL sp_promote_staging_to_final();
SHOW TABLES;

/*Final Project part 2, Part 1: Integrating Data from an API, 
4. Load into a staging table, then into a permanent support_ticket table in your Project
 1 database. Match each ticket to an existing customer by email and product by SKU, 
 using the same approach you already built.*/
DROP TABLE IF EXISTS stg_support_ticket;
CREATE TABLE stg_support_ticket (
    ticket_id           VARCHAR(20),
    opened_at           VARCHAR(20),
    product_sku         VARCHAR(20),
    issue_type          VARCHAR(50),
    status              VARCHAR(20),
    resolution_days     VARCHAR(20),
    satisfaction_score  VARCHAR(20),
    customer_email     VARCHAR(255)
);
SELECT * FROM stg_support_ticket;
SELECT COUNT(*) AS num_rows FROM stg_support_ticket;
SELECT COUNT(*) AS num_rows FROM customer_survey;
SELECT COUNT(*) AS num_rows FROM customers;
SELECT COUNT(*) AS num_rows FROM products;
SELECT COUNT(*) AS num_rows FROM web_feedback_from_json;
-- SELECT * FROM external_reviews_native;
SELECT * FROM customer_survey;
SELECT * FROM web_feedback_from_json;
SELECT * FROM customers;
SELECT * FROM products;
SELECT * FROM reviews;
/*Load the data into stg-support-ticket*/
/*csv from json in python*/
/*Match each ticket to an existing customer by email and product by SKU, 
 using the same approach you already built.*/ 
SELECT * FROM stg_support_ticket;
ALTER TABLE customers RENAME COLUMN email TO customer_email;
SELECT
    st.ticket_id,
    st.product_sku,
    st.customer_email,
    c.name AS Customer_Name,
    p.SKU AS Product_SKU,
    p.name AS Product_Name
FROM stg_support_ticket st
LEFT JOIN customers c
    ON LOWER(TRIM(st.customer_email)) = LOWER(TRIM(c.customer_email))
LEFT JOIN products p
    ON LOWER(TRIM(st.product_sku)) = LOWER(TRIM(p.SKU));
    
/*Verify if they match*/
SELECT
    COUNT(*) AS total_tickets,
    SUM(CASE WHEN c.customerid IS NULL THEN 1 ELSE 0 END) AS unmatched_customers,
    SUM(CASE WHEN p.productid IS NULL THEN 1 ELSE 0 END) AS unmatched_products
FROM stg_support_ticket st
LEFT JOIN customers c ON LOWER(TRIM(st.customer_email)) = LOWER(TRIM(c.customer_email))
LEFT JOIN products p ON LOWER(TRIM(st.product_sku)) = LOWER(TRIM(p.SKU));
/*5.Compare the API to the file sources in a short paragraph: what was harder about it, and what would break if the API were unavailable when your load ran.*/
/*File sources CSV,JSON and XML sources in this project has a difficult part when I tried to fetch in MySQL (JSON, XML) with LOAD LOCAL INFILE option and
got the error 'disable security option' and that took me long time to discover the right path and how remove the option into the terminal and after that was
quick to move forward, also I journey in the entire MYSQL to disable, and the when I understood why we need to applied this process was more reasonable, 
the only things it was to disable again, that was another  extra time to turn OFF again.

Instead the API's it was complicated find the mock_api files, in the begining I tought was the regular instalation, 
it was super complicated to find the right way also agains time but how I had alreary experience with the other files with similar process, 
I imagined it was similar so I tried to find the information in the regular package in Python but I wasnt the right way and then when I search 
information about the terminal and search into the powarshell, that part to get the right folder and enter into mock folder and then understand 
to attached into my final project files was a ticky. I wasnt a regular API fetching also this technique I was to apply also in the middle the coding 
and actived the most hard was to fectch and find the right key words in json file,and in Python find the right way to active the mock file, the funny things 
the instructions mentioned after I find the folder in the terminal write the script in Python and I write the sript in the terminal and I got errors
and then I understood I write my script in MyPythonCharm and run. In my consideration, both process were complicated because I am not familiarized with
this process, but It was good practice and learn how can simulate the apis in Python*/

SHOW GLOBAL VARIABLES LIKE 'local_infile';
SET GLOBAL local_infile = 0;
SHOW GLOBAL VARIABLES LIKE 'local_infile';

/*Part 2: Designing the Warehouse
Design a star schema for feedback analysis. You need one fact table and a 
set of dimensions. Draw it, a simple diagram is fine; it does not need to be a full ER diagram.*/
DROP TABLE IF EXISTS OrdersFact;
CREATE TABLE OrdersFact (
    OrdersFactID INT AUTO_INCREMENT PRIMARY KEY,
    ReviewID     INT,
    CustomerID   INT,
    ProductID    INT,
    DateID       INT,
    Rating       INT NOT NULL CHECK (Rating BETWEEN 1 AND 5),
    Price        DECIMAL(10,2) NOT NULL CHECK (Price >= 0),
    Category     VARCHAR(100) NOT NULL,
    Comments     TEXT,                        
    SKU          VARCHAR(255) NOT NULL,
    FOREIGN KEY (ReviewID)   REFERENCES Reviews(ReviewID),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    FOREIGN KEY (ProductID)  REFERENCES Products(ProductID),
    FOREIGN KEY (DateID)     REFERENCES Dim_Date(DateID)
) ENGINE=InnoDB;

/*Load Data into the OrdersFact*/
INSERT INTO OrdersFact
    (ReviewID, CustomerID, ProductID, DateID,
     Rating, Price, Category, Comments, SKU)
SELECT
    r.ReviewID, r.CustomerID, r.ProductID, d.DateID,
    r.Rating, p.Price, p.Category, r.Comments, p.SKU
FROM Reviews r
JOIN Products p
    ON r.ProductID = p.ProductID
LEFT JOIN Customers c
    ON r.CustomerID = c.CustomerID
LEFT JOIN Dim_Date d
    ON d.Full_date = DATE(r.Full_Date)
LIMIT 10;
/*Verify the loading*/
SELECT COUNT(*) FROM Dim_Date;
SELECT COUNT(*) FROM OrdersFact;
SELECT MIN(Full_Date), MAX(Full_Date) FROM Reviews;
SELECT COUNT(*) FROM OrdersFact;
SELECT * FROM OrdersFact;
SELECT * FROM products;
SELECT * FROM reviews;
/*Verification*/
SELECT o.OrdersFactID, d.Full_Date, o.Rating, o.Price
FROM OrdersFact o
JOIN Dim_Date d ON o.DateID = d.DateID;
/*3.3.	Build a date dimension covering the range of your data, including year, quarter, 
month, month name, and day of the week. Generate it with SQL rather than typing it. */
SELECT * FROM Dim_Date;
SELECT COUNT(*) AS TotalDays,
       MIN(Full_Date) AS EarliestDate,
       MAX(Full_Date) AS LatestDate
FROM Dim_Date;
/*4. Use surrogate keys in the warehouse rather than reusing operational IDs, and explain in one paragraph why a warehouse normally does so.
- I applies Dim_Date.DateID already is a surrogate key in spirit (it's system-generated in the YYYYMMDD format, not borrowed from any source system). 
But Reviews.ReviewID, Customers.CustomerID, and Products.ProductID are being reused directly as the join keys in OrdersFact rather than the fact table
 generating its own surrogate keys for dim_customer, dim_product, etc. and mapping the operational IDs into a lookup table. */
 
 /*5. Add tickets as a second fact table that shares the same product, customer, and date dimensions. 
 - Dimensions used by more than one fact table are called conformed; say what would go wrong if each fact table had its own 
 copy of the product dimension instead.*/
/*NOTE = one row = one support ticket, opened by one customer, about one product, on one date.*/
/*Create dim products I alreary create dim for customer and dim*/
SELECT * FROM stg_support_ticket;
SELECT * FROM dim_date;
SELECT * FROM dim_customer;
SELECT * FROM dim_product;

DROP TABLE IF EXISTS DIM_PRODUCT;
CREATE TABLE DIM_PRODUCT (
    product_key     INT AUTO_INCREMENT PRIMARY KEY,   
    product_id      INT NULL,                         
    sku             VARCHAR(20) NOT NULL,           
    name            VARCHAR(150) NOT NULL,
    category        VARCHAR(50) NOT NULL,
    price           DECIMAL(10,2) NULL,
    is_current      BOOLEAN NOT NULL DEFAULT TRUE,
    effective_date  DATE NULL,
    expiry_date     DATE NULL,
    CONSTRAINT uq_dim_product_sku UNIQUE (sku)
);
CREATE INDEX idx_dim_product_category ON DIM_PRODUCT (category);
/*Populate dim_produc*/
INSERT INTO DIM_PRODUCT (product_id, sku, name, category, price)
SELECT
    NULL,                                   
    s.product_sku,
    CONCAT('Unknown Product (', s.product_sku, ')'),   
    CASE
        WHEN s.product_sku LIKE 'PC-%' THEN 'Personal Care'
        WHEN s.product_sku LIKE 'OF-%' THEN 'Office'
        WHEN s.product_sku LIKE 'EL-%' THEN 'Electronics'
        WHEN s.product_sku LIKE 'OG-%' THEN 'Outdoor Gear'
        WHEN s.product_sku LIKE 'HK-%' THEN 'Home & Kitchen'
        ELSE 'Unknown'
    END,
    NULL                                        
FROM (
    SELECT DISTINCT product_sku
    FROM stg_support_ticket
) s;
SELECT * FROM DIM_PRODUCT;
/*Alter dim customer*/
ALTER TABLE DIM_CUSTOMER CHANGE COLUMN customer_id customer_key INT NOT NULL AUTO_INCREMENT;
/*Populate DIM_Customer*/
SELECT * FROM DIM_CUSTOMER;
INSERT INTO DIM_CUSTOMER (customer_key, email, customer_name)
SELECT
    c.customerid, 
    c.customer_email,
    c.name
FROM Customers c;
/*Create a second fact table tickets*/
DROP TABLE IF EXISTS Fact_Tickets;
CREATE TABLE FACT_TICKETS (
    ticket_key          INT AUTO_INCREMENT PRIMARY KEY,
    ticket_id           VARCHAR(20) NOT NULL,         
    customer_key       INT NOT NULL,
    product_key         INT NOT NULL,
    DateID            INT NOT NULL,                  
    resolved_date_key   INT NULL,                      
    issue_type          VARCHAR(50) NOT NULL,
    status               VARCHAR(20) NOT NULL,          
    resolution_days      DECIMAL(6,1) NULL,
    satisfaction_score   DECIMAL(3,1) NULL,
    CONSTRAINT fk_ticket_customer
        FOREIGN KEY (customer_key) REFERENCES DIM_CUSTOMER (customer_key),
    CONSTRAINT fk_ticket_product
        FOREIGN KEY (product_key) REFERENCES DIM_PRODUCT (product_key),
    CONSTRAINT fk_ticket_date
        FOREIGN KEY (DateID) REFERENCES DIM_DATE (DateID),
    CONSTRAINT fk_ticket_resolved_date
        FOREIGN KEY (resolved_date_key) REFERENCES DIM_DATE (DateID)
);
select * from stg_support_ticket;
select * from dim_customer;
select * from dim_DATE;
-- Indexes on the FK columns, since these will be the join/filter columns
CREATE INDEX idx_fact_tickets_customer ON FACT_TICKETS (customer_key);
CREATE INDEX idx_fact_tickets_product  ON FACT_TICKETS (product_key);
CREATE INDEX idx_fact_tickets_date     ON FACT_TICKETS (date_key);
DESCRIBE FACT_TICKETS;
INSERT INTO FACT_TICKETS (
    ticket_id, customer_key, product_key, DateID, resolved_date_key,
    issue_type, status, resolution_days, satisfaction_score
)
SELECT
    s.ticket_id,
    c.customer_key,
    p.product_key,
    d.DateID,
    s.resolved.date_key,
    s.issue_type,
    s.status,
    s.resolution_days,
    s.satisfaction_score
FROM stg_support_ticket s
JOIN DIM_CUSTOMER c
    ON c.email = s.customer_email
JOIN DIM_PRODUCT p
    ON p.sku = s.product_sku
JOIN DIM_DATE d
    ON d.full_date = DATE(s.opened_at)
LEFT JOIN DIM_DATE d_resolved
    ON s.status = 'resolved'
    AND d_resolved.full_date = DATE(s.opened_at) + INTERVAL s.resolution_days DAY;