/*Assignment 6: Data Integrity and Security*/
/*Name Ayleen Santander*/
CREATE DATABASE IF NOT EXISTS OnlineStoreDB;
USE OnlineStoreDB;

CREATE TABLE Brands (
    brand_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    country_origin VARCHAR (60),
    website_url VARCHAR (255),
    is_cruelty_free BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
DROP TABLE IF EXISTS Categories;

/*CATEGORIES*/
CREATE TABLE Categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    brand_id INT,
    FOREIGN KEY (brand_id) REFERENCES Brands (brand_id)
);
    
	CREATE TABLE Products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    base_price DECIMAL (10,2) NOT NULL CHECK (base_price >= 0),
    is_vegan BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    update_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    brand_id INT NOT NULL,
    category_id INT NOT NULL,
    FOREIGN KEY (brand_ID) REFERENCES Brands (brand_ID),
    FOREIGN KEY (category_ID) REFERENCES Categories (category_ID),
    INDEX idx_products_name (name)
);
	CREATE TABLE Customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR (150) NOT NULL UNIQUE,
    phone VARCHAR (20),
    password_h VARCHAR(255) NOT NULL,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
   INDEX idx_customers_email (email)
);
INSERT INTO Brands (name, country_origin, is_cruelty_free) VALUES
('glow cosmetics', 'canada', TRUE),
('Velour Beauty', 'France', FALSE),
('pureskin', 'USA', TRUE);

INSERT INTO Categories (name,  brand_id) VALUES
('foundation', NULL),
('lipstick', NULL),
('mascara', NULL);

DELETE FROM categories WHERE brand_id =1;
DELETE FROM categories WHERE brand_id =2;
DELETE FROM categories WHERE brand_id =3;
DELETE FROM categories WHERE category_id =9;
DELETE FROM categories WHERE category_id =10;
DELETE FROM categories WHERE category_id =11;
DELETE FROM categories WHERE category_id =12;

SELECT * FROM Categories;
UPDATE categories SET brand_id = 1 WHERE category_id = 4;  
UPDATE categories SET brand_id = 2 WHERE category_id = 5;  
UPDATE categories SET brand_id = 3 WHERE category_id = 6;  
SELECT * FROM Categories;
SELECT * FROM Brands;
SELECT * FROM Customers;
UPDATE customers SET product_id = 7 WHERE customer_id = 1;  
UPDATE customers SET product_id = 8 WHERE customer_id = 2;  
UPDATE customers SET product_id = 9 WHERE customer_id = 3;  
SELECT * FROM Products;

/*add id into them*/
SELECT brand_id, name FROM Brands;
SELECT category_id, name FROM Categories;

INSERT INTO Products (brand_id, category_id, name, description, base_price, is_vegan) VALUES
(1, 4,'matte liquid foundation', 'full-coverage, oil-free, 24hr wear', 34.99, TRUE),
(2, 5,'velvet lipstick', 'long-lasting', 22.50, FALSE),
(3, 6, 'volumizing mascara', 'buildable volumne, water-proof', 18.00, TRUE);

INSERT INTO Customers (first_name, last_name, email, password_h)VALUES
('Ana', 'Rodriguez', 'ana.rodriguez@example.com', 'h_pw_1'),
('Atenea', 'Vasquez', 'atenea.vasquez@example.com', 'h_pw_3'),
('Liam', 'Chen', 'liam.chen@example.com', 'h_pw_2');

/*ADD product_id as a column to Customers, its FK contraint referencing Products*/
ALTER TABLE Customers
ADD COLUMN product_id INT;

ALTER TABLE Customers
ADD CONSTRAINT fk_customers_products
FOREIGN KEY (product_id) REFERENCES Products (product_id);

DESCRIBE Customers;
/*3. Implement Security Measures : Create User Roles and Permissions
Define User Roles:*/
CREATE ROLE 'manager_store';
CREATE ROLE 'attendance_staff';
CREATE ROLE 'catalog_customer';

-- ---------- Grant permissions to each role ----------
-- Manager: full CRUD on everything in the database
GRANT ALL PRIVILEGES ON OnlineStoreDB.* TO manager;
GRANT SELECT, INSERT, UPDATE, DELETE ON Categories TO manager;
GRANT SELECT, INSERT, UPDATE, DELETE ON Products TO manager;
GRANT SELECT, INSERT, UPDATE, DELETE ON Brands TO manager;
GRANT SELECT, INSERT, UPDATE, DELETE ON Customers TO manager;

-- Attendance_staff: can read everything, update data but cannot delete records 
GRANT SELECT, INSERT, UPDATE ON Categories TO attendance_staff;
GRANT SELECT, INSERT ON Products TO attendance_staff;
GRANT SELECT, INSERT ON Brands TO attendance_staff;
GRANT SELECT, INSERT, UPDATE ON Customers TO attendance_staff;

  -- ---------- Catalog_customer: read-only access for catalogs----------
GRANT SELECT ON Categories TO catalog_customer;
GRANT SELECT ON Products TO catalog_customer;
GRANT SELECT ON Brands TO catalog_customer;
SHOW GRANTS FOR catalog_customer;

REVOKE SELECT ON onlinestoredb.customers FROM catalog_customer;
FLUSH PRIVILEGES;
SHOW GRANTS FOR catalog_customer;
-- ---------- Assign roles to actual users ----------
CREATE USER IF NOT EXISTS 'diego_manager'@'%' IDENTIFIED BY 'strong_password_here';
GRANT manager TO 'diego_manager'@'%';
SET DEFAULT ROLE manager TO 'diego_manager'@'%';

CREATE USER IF NOT EXISTS 'pedro_attendance_staff'@'%' IDENTIFIED BY 'your_password_here';
GRANT attendance_staff TO 'pedro_attendance_staff'@'%';
SET DEFAULT ROLE attendance_staff TO 'pedro_attendance_staff'@'%';

CREATE USER IF NOT EXISTS 'diego_catalog_customer'@'%' IDENTIFIED BY 'password_here';
GRANT catalog_customer TO 'diego_catalog_customer'@'%';
SET DEFAULT ROLE catalog_customer TO 'diego_catalog_customer'@'%';

-- ---------- Apply changes ----------
FLUSH PRIVILEGES;

/*-- Run inside the user's own session:*/
SET ROLE ALL;

/*4.Log in as each user.*/ 
-- TEST EACH ROLE FOR REAL, create a new myysql workbench
# Manager  (password: admin_password)
mysql -u admin_user -p
#Attendance_staff   (password: hr_password)
mysql -u hr_user -p
#catalog_customer      (password: emp_password)
mysql -u emp_user -p

/*VERIFY THE GRANTS*/
-- ============================================================
SHOW GRANTS FOR 'manager_user'@'localhost';
SHOW GRANTS FOR 'pedro_attendance_staff'@'%';
SHOW GRANTS FOR 'diego_catalog_customer'@'%';
-- ============================================================
/*Test allowed vs. restricted operations for each role.*/
-- Expected: ALL SUCCEED
/*Manager*/
SELECT * FROM brands;
SELECT * FROM categories;
SELECT * FROM products;
INSERT INTO brands (brand_id, name) VALUES (11, 'Mixsoon');
UPDATE categories SET name = 'koren_cream' WHERE brand_id = 1;
SET SQL_SAFE_UPDATES = 0;
DELETE FROM customers WHERE last_name = 'Chen';
SET SQL_SAFE_UPDATES = 1; 

-- ============================================================
/*attendance_staff*/
-- Expected: ALL SUCCEED
SELECT * FROM customers;
SELECT * FROM products;
SELECT * FROM brands;
UPDATE customers SET first_name = 'Giovana J.' WHERE customer_id = 2;
INSERT INTO customers (customer_id, first_name, last_name, email, password_h) VALUES (5, 'Maite', 'Leyton', 'mleyton@hexample.com','h_pw_20');
UPDATE products SET description = 'real_cream' WHERE product_id = 9;
INSERT INTO brands (brand_id, name) VALUES (12, 'SallyBeauty');

-- Expected: REJECTED
-- Cannot delete customers and products:
DELETE FROM customers WHERE last_name = 'Vasquez';
--  Error Code: 1142. DELETE command denied to user 'pedro_attendance_staff'@'localhost' for table 'customers'	

DELETE FROM products WHERE product_id = 8;
-- Error Code: 1142. DELETE command denied to user 'pedro_attendance_staff'@'localhost' for table 'products'	


/*catalog_customer:*/
/*- -- Expected: ALL SUCCEED*/
SELECT * FROM products;
SELECT * FROM brands;
SELECT * FROM categories;

/*-- Expected: REJECTED (no privileges granted yet)*/
SELECT * FROM customers;
-- Error Code: 1142. SELECT command denied to user 'diego_catalog_customer'@'localhost' for table 'customers'	

-- Cannot update the name column 
UPDATE products SET name = 'Mac' WHERE product_id = 5;
--   Error Code: 1142. UPDATE command denied to user 'diego_catalog_customer'@'localhost' for table 'products'	

-- Cannot insert or delete categories:
INSERT INTO categories (category_id, name, brand_id)
VALUES (8, 'beberage', 4);
--   Error Code: 1142. INSERT command denied to user 'diego_catalog_customer'@'localhost' for table 'categories'	