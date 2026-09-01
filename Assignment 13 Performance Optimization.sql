/*Assignment 13: Performance Optimization*/
CREATE DATABASE IF NOT EXISTS CompanyDB;
USE CompanyDB;

CREATE TABLE departments (
  id INT PRIMARY KEY,
  name VARCHAR(100)
)ENGINE=InnoDB;

CREATE TABLE employees (
  id INT PRIMARY KEY,
  name VARCHAR(100),
  department_id INT,
  salary DECIMAL(10, 2),
  hire_date DATE,
  FOREIGN KEY (department_id) REFERENCES departments(id)
) ENGINE=InnoDB;

INSERT INTO departments (id, name) VALUES
(1, 'HR'),
(2, 'Finance'),
(3, 'IT'),
(4, 'Sales');

INSERT INTO employees (id, name, department_id, salary, hire_date) VALUES
(1, 'Alice', 1, 60000, '2015-03-01'),
(2, 'Bob', 2, 70000, '2016-05-15'),
(3, 'Charlie', 3, 80000, '2017-07-30'),
(4, 'David', 4, 90000, '2018-09-20'),
(5, 'Eve', 1, 75000, '2019-11-10'),
(6, 'Frank', 2, 65000, '2020-01-25'),
(7, 'Grace', 3, 82000, '2021-02-14'),
(8, 'Heidi', 4, 92000, '2022-04-18');

/*Part 2: Create and Analyze Indexes:
1. Create different types of indexes on the employees table.*/
SELECT *
FROM employees;
CREATE INDEX idx_hire_date ON employees(hire_date);
CREATE INDEX idx_salary ON employees(salary);
CREATE INDEX idx_name ON employees(name);
CREATE INDEX idx_department_id ON employees (department_id);
CREATE INDEX idx_department_id ON departments (name);

/*check them*/
DESCRIBE employees;
SHOW COLUMNS FROM employees;
SHOW INDEX FROM employees;
DROP INDEX idx_name_unique ON employees;
DROP INDEX idx_employee_name ON employees;
SHOW INDEX FROM employees;
/*2. Analyze the impact of these indexes on query performance.*/
SELECT * 
FROM employees;

EXPLAIN SELECT name, salary
FROM employees
WHERE salary > 60000
  AND hire_date >= '2018-01-01';


EXPLAIN ANALYZE SELECT name, salary
FROM employees
WHERE salary > 60000
  AND hire_date >= '2018-01-01';

SELECT e.name, e.salary, e.hire_date, d.name AS department_name
FROM employees e
JOIN departments d ON e.department_id = d.id
WHERE e.hire_date > '2006-06-15';

EXPLAIN SELECT e.name, e.salary, e.hire_date, d.name AS department_name
FROM employees e
JOIN departments d ON e.department_id = d.id
WHERE e.hire_date > '2006-06-15';

EXPLAIN ANALYZE SELECT e.name, e.salary, e.hire_date, d.name AS department_name
FROM employees e
JOIN departments d ON e.department_id = d.id
WHERE e.hire_date > '2006-06-15';

SELECT d.id AS department_id, d.name AS department_name, MAX(e.salary) AS highest_salary
FROM employees e
JOIN departments d ON e.department_id = d.id
GROUP BY d.id, d.name
HAVING MAX(e.salary) > 80000;

EXPLAIN SELECT d.id AS department_id, d.name AS department_name, MAX(e.salary) AS highest_salary
FROM employees e
JOIN departments d ON e.department_id = d.id
GROUP BY d.id, d.name
HAVING MAX(e.salary) > 80000;

EXPLAIN ANALYZE SELECT d.id AS department_id, d.name AS department_name, MAX(e.salary) AS highest_salary
FROM employees e
JOIN departments d ON e.department_id = d.id
GROUP BY d.id, d.name
HAVING MAX(e.salary) > 80000;



SELECT e.name AS employee_name, d.name AS department_name, e.salary
FROM employees e
JOIN departments d ON e.department_id = d.id
WHERE e.name = 'Frank'
   OR d.name = 'Finance';

SELECT name, department_id
FROM employees
WHERE name= 'Frank';

/*2.Rewrite Queries for Optimization:
1. Rewrite existing queries to improve their performance.*/
/*2. Use the EXPLAIN command to analyze and compare the execution plans before and after rewriting.*/
EXPLAIN SELECT e.name, e.salary, e.hire_date, d.name AS department_name
FROM employees e
JOIN departments d ON e.department_id = d.id
WHERE e.hire_date > '2006-06-15';

EXPLAIN ANALYZE SELECT e.name, e.salary, e.hire_date, d.name AS department_name
FROM employees e
JOIN departments d ON e.department_id = d.id
WHERE e.hire_date > '2006-06-15';

EXPLAIN SELECT * 
FROM departments d 
JOIN employees e ON d.id = e.id 
WHERE e.name = 'Charlie';

EXPLAIN ANALYZE SELECT * 
FROM departments d 
JOIN employees e ON d.id = e.id 
WHERE e.name = 'Charlie';

EXPLAIN SELECT * 
FROM employees
WHERE salary > 60000
  AND hire_date >= '2018-01-01';
  
SELECT name, salary, hire_date
FROM employees
WHERE salary > 60000
  AND hire_date >= '2018-01-01';
  
EXPLAIN SELECT name, salary, hire_date
FROM employees
WHERE salary > 60000
  AND hire_date >= '2018-01-01';
  
EXPLAIN ANALYZE SELECT name, salary, hire_date
FROM employees
WHERE salary > 60000
  AND hire_date >= '2018-01-01';
  
EXPLAIN SELECT name, department_id
FROM employees
WHERE name = 'Frank';

EXPLAIN ANALYZE SELECT name, department_id
FROM employees
WHERE name = 'Frank';

EXPLAIN SELECT d.id AS department_id, d.name AS department_name, MAX(e.salary) AS highest_salary
FROM employees e
JOIN departments d ON e.department_id = d.id
GROUP BY d.id, d.name
HAVING MAX(e.salary) > 80000;

EXPLAIN ANALYZE SELECT d.id AS department_id, d.name AS department_name, MAX(e.salary) AS highest_salary
FROM employees e
JOIN departments d ON e.department_id = d.id
GROUP BY d.id, d.name
HAVING MAX(e.salary) > 80000;

EXPLAIN SELECT d.id AS department_id, d.name AS department_name, e.name AS EmployeesFullName, e.salary AS Lowest_salary
FROM employees e
JOIN departments d ON e.department_id = d.id
WHERE e.salary < 79000;

EXPLAIN ANALYZE SELECT d.id AS department_id, d.name AS department_name, e.name AS EmployeesFullName, e.salary AS Lowest_salary
FROM employees e
JOIN departments d ON e.department_id = d.id
WHERE e.salary < 79000;

EXPLAIN SELECT e.name AS employee_name, d.name AS department_name, e.salary
FROM employees e
JOIN departments d ON e.department_id = d.id
WHERE d.name = 'Finance'
   OR e.name = 'Frank';
   
EXPLAIN ANALYZE SELECT e.name AS employee_name, d.name AS department_name, e.salary
FROM employees e
JOIN departments d ON e.department_id = d.id
WHERE d.name = 'Finance'
   OR e.name = 'Frank';
   
