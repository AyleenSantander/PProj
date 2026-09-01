/*Assignment 12: SQL Functions and Procedures*/
/*Name Ayleen Santander */
CREATE DATABASE IF NOT EXISTS MeprestasDB;
USE MeprestasDB;
/*ENGINE = InnoDB;  = statement specifies which storage engine MySQL and ENGINE=MyISAM; = MySQL's original default engine (before InnoDB)
No foreign key support, no transactions (COMMIT/ROLLBACK don't apply)*/
CREATE TABLE books (
    book_id INT PRIMARY KEY,
    title VARCHAR(255),
    author VARCHAR(255),
    publication_date DATE,
    price DECIMAL(10, 2)
) ENGINE=InnoDB;

CREATE TABLE members (
    member_id INT PRIMARY KEY,
    member_name VARCHAR(255),
    email VARCHAR(255),
    phone VARCHAR(20)
)ENGINE=InnoDB;

CREATE TABLE loans (
    loan_id INT PRIMARY KEY,
    book_id INT,
    member_id INT,
    loan_date DATE,
    return_date DATE,
    FOREIGN KEY (book_id) REFERENCES books(book_id),
    FOREIGN KEY (member_id) REFERENCES members(member_id)
)ENGINE=InnoDB;

INSERT INTO books (book_id, title, author, publication_date, price) VALUES
(1, 'To Kill a Mockingbird', 'Harper Lee', '1960-07-11', 10.99),
(2, '1984', 'George Orwell', '1949-06-08', 8.99),
(3, 'The Great Gatsby', 'F. Scott Fitzgerald', '1925-04-10', 12.99),
(4, 'Pride and Prejudice', 'Jane Austen', '1813-01-28', 9.99);

INSERT INTO members (member_id, member_name, email, phone) VALUES
(1, 'Alice Johnson', 'alice.johnson@example.com', '123-456-7890'),
(2, 'Bob Smith', 'bob.smith@example.com', '098-765-4321');

INSERT INTO loans (loan_id, book_id, member_id, loan_date, return_date) VALUES
(1, 1, 1, '2023-01-01', '2023-01-15'),
(2, 2, 2, '2023-01-10', NULL);

/*1. Create Scalar Functions:
1. Create a scalar function to calculate the total price of a book after applying a discount. 
The function should take the original price and the discount percentage as input and return the discounted price.*/
DELIMITER //

CREATE FUNCTION total_price_of_book (
original_price DECIMAL(10,2),
discount_percentage DECIMAL(5,2)
)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
RETURN original_price - (original_price * discount_percentage / 100);
END //

DELIMITER ;
/*test it*/
SELECT total_price_of_book(100.00, 20.00) AS DiscountedPrice;

/*2. Create Stored Procedures:
Create a stored procedure to add a new book to the books table. 
The procedure should accept parameters for book_id, title, author, publication_date, and price. Test the procedure by inserting the following book:
5, 'Moby Dick', 'Herman Melville', '1851-11-14', 11.99*/
SELECT *
FROM Books;
DESCRIBE Books;

DELIMITER //
 
CREATE PROCEDURE insert_new_book (IN book_id INT, IN title VARCHAR (255), IN Author VARCHAR (255), IN publication_date DATE, IN price DECIMAL (10,2)
)
BEGIN
	INSERT INTO Books(book_id, title, author, publication_date, price)
	VALUES(book_id, title, author, publication_date, price);
END //

DELIMITER ;
CALL insert_new_book(5, 'Moby Dick', 'Herman Melville', '1851-11-14', 11.99);

/*Retrieve the procedure*/
SHOW PROCEDURE STATUS WHERE Db = 'MeprestasDB';

/*3. Create a stored procedure to update the price of a book based on its book_id. 
After creating the procedure, execute it to change the price of book_id 2 to 7.99.*/
/* I need to drop the procedure and create again for error and misspell the columns name*/
DROP PROCEDURE IF EXISTS update_price_book;
DELIMITER //

CREATE PROCEDURE update_price_book (IN p_book_id INT, IN p_price DECIMAL(10,2)
)
BEGIN
    UPDATE Books SET Price = price WHERE book_id = book_id;
END //

DELIMITER ;
/*Verify it works*/
SELECT * FROM Books WHERE book_id = 2;
/*Retrieve the procedure*/
SHOW PROCEDURE STATUS WHERE Db = 'MeprestasDB';

/*4. Create a stored procedure to retrieve all overdue loans. A loan is considered overdue if return_date IS NULL and the 
loan_date is more than 30 days before the current date.
Use CURDATE() for date calculations.*/
DESCRIBE loans;
DELIMITER //

CREATE PROCEDURE retrieve_all_overdue_loans ()
BEGIN
SELECT loan_id, member_id, loan_date, return_date
FROM loans
WHERE return_date IS NULL
  AND loan_date < CURDATE() - INTERVAL 30 DAY;
END //

DELIMITER ;
/*Retrieve the procedure*/
SHOW PROCEDURE STATUS WHERE Db = 'MeprestasDB';

/*NOTE CURDATE is a built-in MySQL function that returns today's date */
SELECT CURDATE();