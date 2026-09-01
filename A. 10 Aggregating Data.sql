/*Assignment 10 Aggregating Data*/
CREATE DATABASE IF NOT EXISTS NinaCoDB;
USE NinaCoDB;

/*Create a tables*/
CREATE TABLE Employees(
EmployeeID INT PRIMARY KEY,
FirstName VARCHAR (50),
LastName VARCHAR (50),
Department VARCHAR (50), 
Salary DECIMAL (10,2)
);

INSERT INTO Employees (EmployeeID, FirstName, LastName, Department, Salary) VALUES 
(1, 'John', 'Doe', 'IT', 70000),
(2, 'Jane', 'Smith', 'HR', 65000),
(3, 'Robert', 'Brown', 'IT', 80000),
(4, 'Emily', 'Davis', 'HR', 62000),
(5, 'Michael', 'Johnson', 'Finance', 75000),
(6, 'Sarah', 'Lee', 'Finance', 71000),
(7, 'David', 'Wilson', 'IT', 78000),
(8, 'Laura', 'Clark', 'Marketing', 60000),
(9, 'Daniel', 'Lewis', 'Marketing', 62000),
(10, 'Sophia', 'Walker', 'IT', 72000),
(11, 'James', 'Hall', 'Finance', 79000),
(12, 'Olivia', 'Young', 'HR', 68000),
(13, 'William', 'Allen', 'IT', 73000),
(14, 'Mia', 'King', 'Marketing', 58000),
(15, 'Benjamin', 'Scott', 'IT', 77000);

CREATE TABLE Sales(
SalesID INT PRIMARY KEY,
ProductName VARCHAR (100),
ProductCatetory VARCHAR (50),
SalesAmount DECIMAL (10,2), 
SaleDate DATE
);

SELECT *
FROM Sales;
DESCRIBE Sales;

ALTER TABLE Sales ADD COLUMN ProductCategory VARCHAR(100);


INSERT INTO Sales (SalesID, ProductName, ProductCategory, SalesAmount, SaleDate) VALUES
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

ALTER TABLE Sales DROP COLUMN ProductCatetory;

CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    CustomerID INT,
    OrderDate DATE,
    TotalAmount DECIMAL(10, 2)
);

INSERT INTO Orders (OrderID, CustomerID, OrderDate, TotalAmount) VALUES
(1, 1, '2024-06-01', 619.98),
(2, 2, '2024-06-02', 999.99),
(3, 1, '2024-06-03', 299.99),
(4, 3, '2024-06-04', 199.99),
(5, 2, '2024-06-05', 29.99),
(6, 4, '2024-06-06', 199.99),
(7, 3, '2024-06-07', 599.99),
(8, 5, '2024-06-08', 999.99),
(9, 4, '2024-06-09', 19.99),
(10, 5, '2024-06-10', 129.99);

CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Email VARCHAR(100)
);


INSERT INTO Customers (CustomerID, FirstName, LastName, Email) VALUES
(1, 'John', 'Doe', 'john.doe@example.com'),
(2, 'Jane', 'Smith', 'jane.smith@example.com'),
(3, 'Robert', 'Brown', 'robert.brown@example.com'),
(4, 'Emily', 'Davis', 'emily.davis@example.com'),
(5, 'Michael', 'Johnson', 'michael.johnson@example.com');

/*Write aggregation functions*/
/*1.Find the average salary for each department but only include departments with more than 3 employees.*/
SELECT Department, AVG(Salary) AS AverageSalary
FROM Employees
GROUP BY Department
HAVING COUNT(*) > 3;

/*2.List the total sales for each product category, but only include categories where the total sales amount exceeds $500.*/
SELECT ProductCategory, SUM(SalesAmount) AS TotalSalesAmount
FROM Sales
GROUP BY ProductCategory
HAVING TotalSalesAmount > 500;

/*3. Determine the total number of orders placed by each customer*/
SELECT CustomerID, COUNT(*) AS NumberOfOrders
FROM Orders
GROUP BY CustomerID;

/*Additional Join Customers vs Orders to show customer name*/
SELECT c.CustomerID, c.FirstName, c.LastName, COUNT(*) AS NumberOfOrders
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID, c.FirstName, c.LastName;


/*4. Find the total amount spent by each customer, but only include customers who have spent more than $1000.*/
SELECT *
FROM Customers;
SELECT *
FROM Orders;
SELECT CustomerID, SUM(TotalAmount) AS TotalAmountSpent
FROM Orders 
GROUP BY CustomerID
HAVING SUM(TotalAmount) > 1000;

/*Additional Join Customer vs Orders to show the customer names*/
SELECT c.CustomerID, c.FirstName, c.LastName, SUM(o.TotalAmount) AS TotalAmountSpent
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID, c.FirstName, c.LastName
HAVING SUM(o.TotalAmount) > 1000;

/*5. Calculate the total number of sales and average sales amount for each month in 2024.*/
SELECT *
FROM Sales;
SELECT 
    MONTH(SaleDate) AS SaleMonth,
    COUNT(*) AS TotalNumberOfSales,
    AVG(SalesAmount) AS AverageSalesAmount
FROM Sales
WHERE YEAR(SaleDate) = 2024
GROUP BY MONTH(SaleDate)
ORDER BY SaleMonth; 

/*Part 2: Combining Multiple Tables*/
/*1. List the total amount spent by each customer along with their names.*/
SELECT *
FROM Orders;

SELECT c.CustomerID, c.FirstName, c.LastName, SUM(o.TotalAmount) AS TotalAmountSpent
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID, c.FirstName, c.LastName;

/*2. Find the average order amount for each customer, but only include those with more than 2 orders.*/
SELECT *
FROM Orders;

SELECT CustomerID, AVG(TotalAmount) AS AverageOrderValue
FROM Orders
GROUP BY CustomerID
HAVING COUNT(*) >= 2
ORDER BY AverageOrderValue DESC;
/*Additional the customer names with join*/
SELECT c.CustomerID, c.FirstName, c.LastName, AVG(o.TotalAmount) AS AverageOrderValue
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID, c.FirstName, c.LastName
HAVING COUNT(*) >= 2
ORDER BY AverageOrderValue DESC;

/*3. List the total salary and number of employees for each department and include only departments where the average salary exceeds $70,000.*/
SELECT *
FROM Employees;

SELECT Department, SUM(Salary) AS TotalSalary, COUNT(*) AS TotalNumberOfEmployees
FROM Employees
GROUP BY Department
HAVING AVG(Salary) > 70000
ORDER BY TotalSalary DESC;

/*4. Calculate the total sales amount for each product category for sales made after June 1, 2024.*/
SELECT 
     ProductCategory, 
     SUM(SalesAmount) AS TotalSalesAmount
FROM Sales
WHERE SaleDate > '2024-06-01'
GROUP BY ProductCategory
ORDER BY TotalSalesAmount;

/*5. Find the total number of employees and the total salary paid in each department, sorted by the total salary in descending order.*/
SELECT *
FROM Employees;

SELECT Department, COUNT(*) AS TotalNumberOfEmployees,SUM(Salary) AS TotalSalaryPaid
FROM Employees
GROUP BY Department
ORDER BY TotalSalaryPaid DESC;
    



