/*Assignment 11: Data Manipulation*/
/*Name Ayleen Santander*/

CREATE DATABASE IF NOT EXISTS CompanySalesDB1;
USE CompanySalesDB1;

CREATE TABLE Sales (
    SaleID INT PRIMARY KEY,
    ProductName VARCHAR(100),
    ProductCategory VARCHAR(50),
    SalesAmount DECIMAL(10, 2),
    SaleDate DATE
);

CREATE TABLE SalesBackup (
    SaleID INT PRIMARY KEY,
    ProductName VARCHAR(100),
    ProductCategory VARCHAR(50),
    SalesAmount DECIMAL(10, 2),
    SaleDate DATE
);
SELECT *
FROM SalesBackup;

/*Copy values from sales to salesbackup insert values into backup table*/
INSERT INTO SalesBackup (SaleID, ProductName, ProductCategory, SaleDate)
SELECT SaleID, ProductName, ProductCategory, SaleDate 
FROM Sales;

SELECT *
FROM SalesBackup;

/*Insert values into sales table*/
INSERT INTO Sales (SaleID, ProductName, ProductCategory, SalesAmount, SaleDate) VALUES
(1, 'Smartphone', 'Electronics', 599.99, '2024-01-15'),
(2, 'Laptop', 'Electronics', 999.99, '2024-02-20'),
(3, 'Tablet', 'Electronics', 299.99, '2024-03-10'),
(4, 'Headphones', 'Electronics', 199.99, '2024-04-05'),
(5, 'Novel', 'Books', 19.99, '2024-05-25'),
(6, 'Cookbook', 'Books', 29.99, '2024-06-14'),
(7, 'Biography', 'Books', 24.99, '2024-07-22'),
(8, 'Smartwatch', 'Electronics', 199.99, '2024-08-30'),
(9, 'E-Reader', 'Electronics', 129.99, '2024-09-17'),
(10, 'Fiction Book', 'Books', 14.99, '2024-10-08'); 

SELECT *
FROM Sales;

/*1. Retrieve all records from the Sales table*/
SELECT *
FROM Sales;

/*2. Retrieve sales records for Electronics category*/
SELECT *
FROM Sales
WHERE ProductCategory = 'Electronics';
/*3. Retrieve sales records where SalesAmount is greater than 500*/
SELECT *
FROM Sales
WHERE SalesAmount >500;

/*4.Insert a new sales record into the Sales table:
SaleID = 11, ProductName = Gaming Console, ProductCategory = Electronics, SalesAmount = 499.99, SaleDate = 2024-11-01*/
INSERT INTO Sales (SaleID, ProductName, ProductCategory, SalesAmount, SaleDate) VALUES
(11, 'Gaming Console', 'Electronics', 499.99, '2024-11-01');

/*Check values*/
SELECT * 
FROM Sales;

/*5. Insert multiple sales records into the Sales table:
SaleID = 12, ProductName = Action Figure, ProductCategory = Toys, SalesAmount = 24.99, SaleDate = 2024-11-02
SaleID = 13, ProductName = Board Game, ProductCategory = Toys, SalesAmount = 39.99, SaleDate = 2024-11-03*/
INSERT INTO Sales (SaleID, ProductName, ProductCategory, SalesAmount, SaleDate) VALUES
(12, 'Action Figure', 'Toys', 24.99, '2024-11-02'),
(13, 'Board Game', 'Toys', 39.99, '2024-11-03');
/*Check update*/
SELECT * 
FROM Sales;

/*6. Update the SalesAmount of SaleID 1 to 549.99*/
SELECT * 
FROM Sales;

UPDATE Sales SET SalesAmount = 549.99 WHERE SaleID = 1;

SELECT * 
FROM Sales;

/*7.Delete the Sale record of SaleID 10*/
DELETE FROM Sales WHERE SaleID = 10;

/*Verify delete*/
SELECT *
FROM Sales;

/*8. Delete all sales records for the Toys category, (This DELETE filters by category, not a key column, 
so watch for Safe Update Mode — see the note above.)*/
SET SQL_SAFE_UPDATES = 0;

DELETE FROM Sales
WHERE ProductCategory = 'Toys';

SET SQL_SAFE_UPDATES = 1;  -- turn it back on afterward

/*Verify changes*/
SELECT *
FROM Sales;

/*9. Transfer all sales records from 'Books' category to 'Literature' category in one transaction*/
SET SQL_SAFE_UPDATES = 0;

START TRANSACTION;
UPDATE Sales
SET ProductCategory = 'Literature'
WHERE ProductCategory = 'Books';
SET SQL_SAFE_UPDATES = 1; 

/*check the result before committing*/
SELECT * 
FROM Sales 
WHERE ProductCategory = 'Literature';

COMMIT;
/*Check values*/
SELECT *
FROM Sales;

/*10. Begin a transaction, delete a sale by mistake, then ROLLBACK so the deletion is undone. 
Run a SELECT before and after to prove the row is restored.*/
/*Checl the row if exists in the table*/
SELECT *
FROM Sales
WHERE SaleID =8;

START TRANSACTION;
/* "Accidentally" delete it a row 8*/
DELETE FROM Sales 
WHERE SaleID = 8;

/*Check values immediately after the delete, while still inside the transaction*/
SELECT *
FROM Sales
WHERE SaleID = 8;
/*Undo the mistake*/
ROLLBACK;

/*Check values AFTER the rollback — should show the row is back*/
SELECT *
FROM Sales
WHERE SaleID = 8;

